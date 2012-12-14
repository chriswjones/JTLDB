JTLDB
=====

## What is JTLDB?
JTLDB is a fully asynchronous and thread safe ObjectiveC SQLite wrapper that allows for concurrent reading and writing.  It was developed to facilitate easy SQLite use in iOS apps, specifically apps that use some sort of a sync model between the device and server.

## Installation Instructions

1. Add JTLDB as a submodule of you project
```
$ cd /path/to/MyApplication
# If this is a new project, initialize git...
$ git init
$ git submodule add git://github.com/jtlsystems/JTLDB.git
```
2. Add the JTLDB project to your XCode Workspace

## How to Use JTLDB with Data Layer Separation, Versioning and Easy Entity Creation from Reads
Please checkout the [JTLDB Demo Project]() _demo project coming soon_ for a good example of how to effectively use JTLDB.

## Contributing
Want to contribute? Fork the repo and send us a pull request.

## Copyright and license
Copyright 2012 JTL Systems

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this work except in compliance with the License.
You may obtain a copy of the License in the LICENSE file, or at:

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
