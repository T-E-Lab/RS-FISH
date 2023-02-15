/*-
 * #%L
 * A plugin for radial symmetry localization on smFISH (and other) images.
 * %%
 * Copyright (C) 2016 - 2023 RS-FISH developers.
 * %%
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 2 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public
 * License along with this program.  If not, see
 * <http://www.gnu.org/licenses/gpl-2.0.html>.
 * #L%
 */
package gui.interactive;

import java.awt.Button;
import java.awt.Frame;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.Label;
import java.awt.Scrollbar;

public class DoGWindow
{
	final InteractiveRadialSymmetry parent;
	final Frame doGFrame;

	public DoGWindow( final InteractiveRadialSymmetry parent )
	{
		this.parent = parent;
		this.doGFrame = new Frame( "Adjust difference-of-gaussian values" );
		doGFrame.setSize(360, 150);

		/* Instantiation */
		final GridBagLayout layout = new GridBagLayout();
		final GridBagConstraints c = new GridBagConstraints();

		int scrollbarInitialPosition = HelperFunctions.computeScrollbarPositionFromValue(parent.params.getSigmaDoG(), InteractiveRadialSymmetry.sigmaMin, InteractiveRadialSymmetry.sigmaMax, parent.scrollbarSize);
		final Scrollbar sigma1Bar = new Scrollbar(Scrollbar.HORIZONTAL, scrollbarInitialPosition, 10, 0, 10 + parent.scrollbarSize);

		final float log1001 = (float) Math.log10(parent.scrollbarSize + 1)/(float)Math.log10( 2 );
		scrollbarInitialPosition = (int) Math.round(1001 - Math.pow(2, (InteractiveRadialSymmetry.thresholdMax - parent.params.getThresholdDoG()) / (InteractiveRadialSymmetry.thresholdMax - InteractiveRadialSymmetry.thresholdMin) * log1001));
		final Scrollbar thresholdBar = new Scrollbar(Scrollbar.HORIZONTAL, scrollbarInitialPosition, 10, 0, 10 + parent.scrollbarSize);

		final Label sigmaText1 = new Label("Sigma = " + String.format(java.util.Locale.US, "%.2f", parent.params.getSigmaDoG()),
				Label.CENTER);

		final Label thresholdText = new Label("Threshold = " + String.format(java.util.Locale.US, "%.5f", parent.params.getThresholdDoG()), Label.CENTER);
		final Button button = new Button("Done");
		final Button cancel = new Button("Cancel");

		/* Location */
		doGFrame.setLayout(layout);

		// insets constants
		int inTop = 0;
		int inRight = 5;
		int inBottom = 0;
		int inLeft = inRight;

		c.fill = GridBagConstraints.HORIZONTAL;
		c.gridx = 0;
		c.gridy = 0;
		c.weightx = 1;
		doGFrame.add(sigmaText1, c);

		++c.gridy;
		c.insets = new Insets(inTop, inLeft, inBottom, inRight);
		doGFrame.add(sigma1Bar, c);

		++c.gridy;
		doGFrame.add(thresholdText, c);

		++c.gridy;
		doGFrame.add(thresholdBar, c);

		// insets for buttons
		int bInTop = 0;
		int bInRight = 120;
		int bInBottom = 0;
		int bInLeft = bInRight;

		 ++c.gridy;
		 c.insets = new Insets(bInTop, bInLeft, bInBottom, bInRight);
		 doGFrame.add(button, c);

		++c.gridy;
		c.insets = new Insets(bInTop, bInLeft, bInBottom, bInRight);
		doGFrame.add(cancel, c);
		
		/* On screen positioning */
		/* Screen positioning */
		int xOffset = 20; 
		int yOffset = 20;
		doGFrame.setLocation(xOffset, yOffset);

		/* Configuration */
		sigma1Bar.addAdjustmentListener(new SigmaListener(parent,sigmaText1, InteractiveRadialSymmetry.sigmaMin, InteractiveRadialSymmetry.sigmaMax, parent.scrollbarSize, sigma1Bar));
		thresholdBar.addAdjustmentListener(new ThresholdListener(parent,thresholdText, parent.scrollbarSize, InteractiveRadialSymmetry.thresholdMin, InteractiveRadialSymmetry.thresholdMax));
		button.addActionListener(new FinishedButtonListener(parent, false));
		cancel.addActionListener(new FinishedButtonListener(parent, true));
		doGFrame.addWindowListener(new FrameListener(parent));
	}

	public Frame getFrame() { return doGFrame; }
}
