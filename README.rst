
.. -*- mode: rst -*-

Graphical Processing Stream
=======================================================

This ensemble of Matlab programs provides an interactive framework for the processing of MEG/EEG data. It uses `Freesurfer <http://surfer.nmr.mgh.harvard.edu/>`_ and `MNE <http://martinos.org/mne>`_. Make sure you have both packages installed and properly instantiated before running GPS: Analysis.

For the purposes of this quick guide, I based it mostly off of `mne-python's git page <https://github.com/mne-tools/mne-python>`_

** The state of the repo on the 'testing' branch supports having a
'GBU_TEST' directory at the same level as the 'GPS' directory this
file is stored within. 

Get the latest code
^^^^^^^^^^^^^^^^^^^

To get the latest code using git, simply type::

    git clone git@github.com:conradarcturus/GPS.git

Initializing GPS
^^^^^^^^^^^^^^^^^^

Run the gps_init.m script in the main folder

Dependencies
^^^^^^^^^^^^

* Matlab
* Probably a toolbox or two from Matlab

* MNE
* Freesurfer

Contact
^^^^^^^^^^^^

Alexander Conrad Nied (Lead Developer)
    anied@cs.washington.edu

David Gow (Project Manager)
    gow@helix.mgh.harvard.edu

Testing Data
^^^^^^^^^^^^^^^^^^^^^^

The test data set to try out the program is not ready yet, but it will be called WPM (Word Picture Matching)

Licensing
^^^^^^^^^

GPS is **BSD-licenced** (3 clause):

	Copyright © 2013, Alexander Conrad Nied
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	    * Redistributions of source code must retain the above copyright
	      notice, this list of conditions and the following disclaimer.
	    * Redistributions in binary form must reproduce the above copyright
	      notice, this list of conditions and the following disclaimer in the
	      documentation and/or other materials provided with the distribution.
	    * Neither the names of MNE-Python authors nor the names of any
	      contributors may be used to endorse or promote products derived from
	      this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
