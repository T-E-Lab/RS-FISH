package cmd;

import java.util.concurrent.Callable;

import org.janelia.saalfeldlab.n5.N5FSReader;
import org.janelia.saalfeldlab.n5.N5Reader;
import org.janelia.saalfeldlab.n5.imglib2.N5Utils;

import compute.RadialSymmetry.Ransac;
import gui.Radial_Symmetry;
import ij.ImageJ;
import ij.ImagePlus;
import net.imglib2.RandomAccessibleInterval;
import net.imglib2.img.display.imagej.ImageJFunctions;
import parameters.RadialSymParams;
import picocli.CommandLine;
import picocli.CommandLine.Option;

public class RadialSymmetry implements Callable<Void> {

	// input file
	@Option(names = {"-i", "--image"}, required = true, description = "input image or N5 container path - if you only provide the image (requires additional -d for N5) the interactive plugin will open, e.g. -i /home/smFish.tif or /home/smFish.n5")
	private String image = null;

	@Option(names = {"-d", "--dataset"}, required = false, description = "if you selected an N5 path, you need to define the dataset within the N5, e.g. -d 'embryo_5_ch0/c0/s0'")
	private String dataset = null;

	// output file
	@Option(names = {"-o", "--output"}, required = true, description = "output CSV file, e.g. -o 'embryo_5_ch0.csv'")
	private String output = null;

	// interactive mode
	@Option(names = {"--interactive"}, required = false, description = "run the plugin interactively, ImageJ window and image pop up (default: false)")
	private boolean interactive = false;

	// RS settings
	@Option(names = {"-a", "--anisotropy"}, required = false, description = "the anisotropy factor (scaling of z relative to xy, can be determined using the anisotropy plugin), e.g. -a 0.8 (default: 1.0)")
	private double anisotropy = 1.0;

	@Option(names = {"-r", "--ransac"}, required = false, description = "which RANSAC type to use, 0 == No RANSAC, 1 == RANSAC, 2 == Multiconsensus RANSAC (default: 1 - RANSAC)")
	private int ransac = 1;

	@Option(names = {"-s", "--sigma"}, required = false, description = "sigma for Difference-of-Gaussian (DoG) (default: 1.5)")
	private double sigma = 1.5;

	@Option(names = {"-t", "--threshold"}, required = false, description = "threshold for Difference-of-Gaussian (DoG) (default: 0.007)")
	private double threshold = 0.007;

	@Option(names = {"-sr", "--supportRadius"}, required = false, description = "support region radius for RANSAC (default: 3)")
	private int supportRadius = 3;

	@Option(names = {"-ir", "--inlierRatio"}, required = false, description = "Minimal ratio of gradients that agree on a spot (inliers) for RANSAC (default: 0.1)")
	private double inlierRatio = 0.1;

	@Option(names = {"-e", "--maxError"}, required = false, description = "Maximum error for intersecting gradients of a spot for RANSAC (default: 1.5)")
	private double maxError = 1.5;

	@Option(names = {"-it", "--intensityThreshold"}, required = false, description = "intensity threshold for localized spots (default: 0.0)")
	private double intensityThreshold = 0.0;

	// background method
	@Option(names = {"-bg", "--background"}, required = false, description = "Background subtraction method, 0 == None, 1 == Mean, 2==Median, 3==RANSAC on Mean, 4==RANSAC on Median (default: 0 - None)")
	private int background = 0;

	@Option(names = {"-bge", "--backgroundMaxError"}, required = false, description = "RANSAC-based background subtraction max error (default: 0.05)")
	private double backgroundMaxError = 0.05;

	@Option(names = {"-bgir", "--backgroundMinInlierRatio"}, required = false, description = "RANSAC-based background subtraction min inlier ratio (default: 0.75)")
	private double backgroundMinInlierRatio = 0.75;

	// only for multiconsensus RANSAC
	@Option(names = {"-rm", "--ransacMinNumInliers"}, required = false, description = "minimal number of inliers for Multiconsensus RANSAC (default: 20)")
	private int ransacMinNumInliers = 20;

	@Option(names = {"-rn1", "--ransacNTimesStDev1"}, required = false, description = "n: initial #inlier threshold for new spot [avg - n*stdev] for Multiconsensus RANSAC (default: 8.0)")
	private double ransacNTimesStDev1 = 8.0;

	@Option(names = {"-rn2", "--ransacNTimesStDev2"}, required = false, description = "n: final #inlier threshold for new spot [avg - n*stdev] for Multiconsensus RANSAC (default: 6.0)")
	private double ransacNTimesStDev2 = 6.0;

	@Override
	public Void call() throws Exception {

		final RadialSymParams params = new RadialSymParams();

		// general
		RadialSymParams.defaultAnisotropy = params.anisotropyCoefficient = anisotropy;
		RadialSymParams.defaultUseAnisotropyForDoG = params.useAnisotropyForDoG = true;
		RadialSymParams.defaultRANSACChoice = ransac;
		params.RANSAC = Ransac.values()[ ransac ]; //"No RANSAC", "RANSAC", "Multiconsensus RANSAC"

		// multiconsensus
		if ( ransac == 2 )
		{
			RadialSymParams.defaultMinNumInliers = params.minNumInliers = ransacMinNumInliers;
			RadialSymParams.defaultNTimesStDev1 = params.nTimesStDev1 = ransacNTimesStDev1;
			RadialSymParams.defaultNTimesStDev2 = params.nTimesStDev2 = ransacNTimesStDev2;
		}

		// advanced
		RadialSymParams.defaultSigma = params.sigma = (float)sigma;
		RadialSymParams.defaultThreshold = params.threshold = (float)threshold;
		RadialSymParams.defaultSupportRadius = params.supportRadius = supportRadius;
		RadialSymParams.defaultInlierRatio = params.inlierRatio = (float)inlierRatio;
		RadialSymParams.defaultMaxError = params.maxError = (float)maxError;
		RadialSymParams.defaultIntensityThreshold = params.intensityThreshold = intensityThreshold;
		RadialSymParams.defaultBsMethodChoice = params.bsMethod = background;
		RadialSymParams.defaultBsMaxError = params.bsMaxError = (float)backgroundMaxError;
		RadialSymParams.defaultBsInlierRatio = params.bsInlierRatio = (float)backgroundMinInlierRatio;
		RadialSymParams.defaultResultsFilePath = params.resultsFilePath = output;

		System.out.println( params.resultsFilePath );
		final ImagePlus imp;

		if ( image.trim().toLowerCase().endsWith( ".n5") )
		{
			if ( dataset == null || dataset.length() < 1 )
				throw new RuntimeException( "no dataset for the N5 container defined, please use -d 'dataset'." );

			final N5Reader n5 = new N5FSReader( image );
			RandomAccessibleInterval img = N5Utils.open( n5, dataset );

			imp = ImageJFunctions.wrap( img, dataset );
			imp.setDimensions( 1, imp.getStackSize(), 1);
		}
		else
		{
			imp = new ImagePlus( image );
		}

		if ( interactive )
		{
			new ImageJ();

			if ( imp.getStackSize() > 1 )
				imp.setSlice( imp.getStackSize() / 2 );
	
			imp.resetDisplayRange();
			imp.show();
	
			new Radial_Symmetry().run( null );
		}

		return null;
	}

	public static final void main(final String... args) {
		new CommandLine( new RadialSymmetry() ).execute( args );
	}
}
