https://github.com/OCR4all/ocr4all-backend.git# ocr4all-backend
Master repository containing all required submodules to get the new OCR4all backend (still WIP) up and running

## Contained submodules
* [ocr4all-app-communication](https://github.com/OCR4all/ocr4all-app-communication)
* [ocr4all-app-spi](https://github.com/OCR4all/ocr4all-app-spi)
* [ocr4all-app-persistence](https://github.com/OCR4all/ocr4all-app-persistence)
* [ocr4all-app-ocrd-communication](https://github.com/OCR4all/ocr4all-app-ocrd-communication)
* [ocr4all-app-ocrd-spi](https://github.com/OCR4all/ocr4all-app-ocrd-spi)
* [ocr4all-app](https://github.com/OCR4all/ocr4all-app)
* [ocr4all-app-ocrd-msa](https://github.com/OCR4all/ocr4all-app-ocrd-msa)

## Getting started
### Requirements
* `git`
* `Java 17`
* `mvn`
* `docker compose`
* `bash` (optional)

### Download
Clone this repository recursively.
```
git clone --recurse-submodules --remote-submodules https://github.com/OCR4all/ocr4all-backend.git
```

An [SSH Public key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
) connected with your GitHub-Account is required.


### Build
To steps are required to build the application:
1. compile the libraries and package the jars: run the bash script `ocr4all-build.sh` with the argument `build`.
1. build `docker` images: run `docker compose` with the argument `build`. The file `docker-env-dev` gives an example of a common setup of a development environment which stores the application data in the user's home directory `${user.home}/ocr4all`.

### Application
To start the application run `docker compose` with the argument `up`. The server HTTP port is set to **9090**. As by build, the file `docker-env-dev`gives an example of a common setup of a development environment.

#### Defaults

The defaults for the application are defined in the file `src/main/resources/application.yml` of the projects `ocr4all-app` and `ocr4all-app-ocrd-msa`. Several profiles are defined that can be used to control the behaviour of the application.

#### Security
Authentication/authorisation is activated in the server profile and deactivated in the desktop profile.

Authentication/authorisation is configured in the following files in the `ocr4all/workspace/.ocr4all` folder (see below for an example setup): users, passwords and groups.
After authentication in the application with administrative rights, the API can be used to manage users, passwords and groups.

A default administrator user is created, if the application has the server and development profile enabled and/or the application property `ocr4all.application.security.administrator.create` is set to `true` and no administrator user exists. The login credentials are
- username: `admin`
- password: `ocr4all`

##### Example: rights management setup
- **File user** `admin:active::Administrator user`
- **File password** (password `ocr4all`) `admin:{bcrypt}$2a$10$rqYn8YjNLzegNMYZVFtvAuwAZBWFgZQ9bprHhjhHnk3oGUPdEPkYq`
- **File group** `admin:active:admin:Administrator group`

#### Using ocr-d processors
Install models in `ocr4all/opt/ocr-d/resources` (see [ocr-d resource list](https://github.com/OCR-D/core/blob/master/ocrd/ocrd/resource_list.yml))
  - **Calamari recognize** download desired [models](https://github.com/Calamari-OCR/calamari_models/releases/tag/1.1) in subfolder `ocrd-calamari-recognize`
  - **Tesserocr recognize** download desired models  in subfolder `ocrd-tesserocr-recognize`

## API 
### API documentation
The Swagger UI for the API documentation can be accessed under `http://localhost:9090/api/doc/swagger-ui/index.html`.

### Example
An example of using the API.
```
instance
Method: GET
URL: http://localhost:9090/api/v1.0/instance

if authentication/authorization is activated, then login - for further communication, use the bearer token from the authorization KEY from the header or the token from the response body
Method: POST
URL: http://localhost:9090/api/v1.0/login
Body:
{
    "username": "admin",
	"password": "ocr4all"
}

create project
Method: GET
URL: http://localhost:9090/api/v1.0/project/create?id=project_01

Add in exchange folder the images
folder: ocr4all/exchange/project_01/images

See running/done jobs
Method: GET
URL: http://localhost:9090/api/v1.0/job/scheduler/snapshot/administration

Import the images in the project from exchange folder
Method: POST
URL: http://localhost:9090/api/v1.0/spi/import/schedule/project_01
Body:
{
"id": "de.uniwuerzburg.zpd.ocr4all.application.core.spi.imp.provider.ImageImport",
"strings": [
{"argument": "source-folder", "value": "images"}
],
"selects": [
{"argument": "image-formats", "values": ["tif"]}
]
}

Create a sandbox
Method: GET
URL: http://localhost:9090/api/v1.0/sandbox/create/project_01?id=sandbox_01

Launch the sandbox
Method: POST
URL: http://localhost:9090/api/v1.0/spi/launcher/schedule/project_01/sandbox_01
Body:
{
"id": "de.uniwuerzburg.zpd.ocr4all.application.core.spi.launcher.provider.SandboxLauncher",
"images": [
{"argument": "images", "values": [1,2,3,4,5,6]}
],
"label": "launcher default with images",
"description": "description launcher default with images"
}
```

* Using ocr-d processors
```
preprocessing: Binarize
Method: POST
URL: http://localhost:9090/api/v1.0/spi/preprocessing/schedule/project_01/sandbox_01
Body:
{
"id": "de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.msa.preprocessing.MsaCISOcropyBinarize",
"parent-snapshot": {"track": []},
"label": "cis binarize default",
"description": "ocr-d cis ocropy binarize default"
}

olr: Segment region
Method: POST
URL: http://localhost:9090/api/v1.0/spi/olr/schedule/project_01/sandbox_01
Body:
{
"id": "de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.msa.olr.MsaTesserocrSegmentRegion",
"parent-snapshot": {"track": [1]},
"label": "tesserocr segment region default",
"description": "ocr-d tesserocr segment region default"
}

olr: Segment line

Method: POST
URL: http://localhost:9090/api/v1.0/spi/olr/schedule/project_01/sandbox_01
Body:
{
"id": "de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.msa.olr.MsaTesserocrSegmentLine",
"parent-snapshot": {"track": [1,1]},
"label": "tesserocr segment line default",
"description": "ocr-d tesserocr segment line default"
}

ocr: Calamari recognize
Method: POST
URL: http://localhost:9090/api/v1.0/spi/ocr/schedule/project_01/sandbox_01
Body:
{
"id": "de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.msa.ocr.MsaCalamariRecognize",
"selects": [ {"argument": "checkpoint_dir", "values": ["fraktur_historical"]} ],
"parent-snapshot": {"track": [1,1,1]},
"label": "Calamari model",
"description": "ocr-d Calamari model fraktur_historical"
}

ocr: Tesserocr recognize
Method: POST
URL: http://localhost:9090/api/v1.0/spi/ocr/schedule/project_01/sandbox_01
Body:
{
"id": "de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.msa.ocr.MsaTesserocrRecognize",
"selects": [{"argument": "model", "values": ["deu", "frk"]}],
"parent-snapshot": {"track": [1,1,1]},
"label": "Tesserocr models",
"description": "ocr-d Tesserocr models deu + frk"
}
```

Results will be available in the following directories:
- **Calamari recognize** `ocr4all/workspace/projects/project_01/sandboxes/sandbox_01/snapshots/derived/1/derived/1/derived/1/derived/1/sandbox`
- **Tesserocr recognize** `ocr4all/workspace/projects/project_01/sandboxes/sandbox_01/snapshots/derived/1/derived/1/derived/1/derived/2/sandbox`
