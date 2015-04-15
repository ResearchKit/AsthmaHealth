Asthma Health
=============
The Asthma Mobile Health study is a personalized app that helps individuals gain greater insight into their asthma, adhere to treatment plans, and avoid triggers. The app presents a variety of surveys to better understand unique triggers for asthma exacerbations, and connects with HealthKit to track inhaler usage and peak flow values. 

Building the App
================

###Requirements

* Xcode 6.3
* iOS 8.3 SDK

###Getting the source

First, check out the source, including all the dependencies:

```
git clone --recurse-submodules https://github.com/ResearchKit/AsthmaHealth.git
```

###Building it

Open the project, `Asthma.xcodeproj`, and build and run.


Other components
================

The [EuroQoL EQ-5D](http://www.euroqol.org/about-eq-5d.html) survey instrument
is used in the shipping app, but has been removed from the open source
version because it is not free to use.

The shipping app also uses OpenSSL to add extra data protection, which
has not been included in the published version of the AppCore
project. See the [AppCore repository](https://github.com/researchkit/AppCore) for more details.

Data upload to [Bridge](http://sagebase.org/bridge/) has been disabled, the logos of the institutions have been removed, and the consent material has been marked as an example.

License
=======

The source in the AsthmaHealth repository is made available under the
following license unless another license is explicitly identified:

```
Copyright (c) 2015, Icahn School of Medicine at Mount Sinai. All rights reserved. 

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

