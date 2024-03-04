# ocr4all-backend
Master repository containing all required submodules to get the new OCR4all backend (still WIP) up and running

## Contained submodules
* [ocr4all-app-persistence](https://github.com/OCR4all/ocr4all-app-persistence)
* [ocr4all-app-spi](https://github.com/OCR4all/ocr4all-app-spi)
* [ocr4all-app-ocrd-spi](https://github.com/OCR4all/ocr4all-app-ocrd-spi)
* [ocr4all-app](https://github.com/OCR4all/ocr4all-app)

## Getting started
### Requirements
* `git`
* `Java 17`
* `mvn`

### Download
Clone this repository recursively.
```
git clone --recurse-submodules --remote-submodules git@github.com:OCR4all/ocr4all-backend.git
```

An [SSH Public key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
) connected with your GitHub-Account is required.


### Build 
To build and run `ocr4all-app`, use your favorite IDE or create a JAR through your terminal:

#### IDE
- installing [Spring Tools](https://spring.io/tools) is highly recommended
- import all contained submodules as Maven projects in the above-mentioned sequence in your IDE
- start the application using `Spring Tools` in `Boot Dashboard`

#### Terminal
- run `mvn clean install` in the projects following this order
  1. ocr4all-app-persistence
  2. ocr4all-app-spi
  3. ocr4all-app-ocrd-spi
- run `mvn clean package` in the project `ocr4all-app` 

### Application

Start the application in the project `ocr4all-app` with `java -jar target/ocr4all-app-1.0-SNAPSHOT.jar`.

#### Defaults

The defaults for the application are defined in the file `src/main/resources/application.yml` of the project `ocr4all-app`. The server HTTP port is set to **8080**. Several profiles are defined that can be used to control the behaviour of the application:
- **desktop** disables security and stores the application data in the user's home directory `${user.home}/ocr4all`.
- **server** enables security and stores the application data in the system directory `/srv/ocr4all`.
- **api** activates the RESTful API interface
- **documentation** activates the RESTful API documentation with Swagger 2 
- **development** uses server HTTP port 9090, provides more logging information and stores application data in the user's home directory `${user.home}/ocr4all`.

The development version uses the following profiles by default: desktop, api, documentation and development.

If you want to e. g. activate the desktop, api, documentation and development profiles you can use the following command:
```
java -jar -Dspring.profiles.active=desktop,api,documentation,development target/<YourJar>.jar
```

#### Security
Authentication/authorisation is activated in the server profile and deactivated in the desktop profile.

Authentication/authorisation is configured in the following files in the `ocr4all/workspace/.ocr4all` folder (see below for an example setup): users, passwords and groups.
After authentication in the application with administrative rights, the API can be used to manage users, passwords and groups.


An default administrator user is created, 
if the application has the server and development profile enabled and/or the application property `ocr4all.application.security.administrator.create` is set to
`true` and no administrator user exists. The login credentials are
- username: `admin`
- password: `ocr4all`


##### Example: rights management setup
- **File user** `admin:active::Administrator user`
- **File password** (password `ocr4all`) `admin:{bcrypt}$2a$10$rqYn8YjNLzegNMYZVFtvAuwAZBWFgZQ9bprHhjhHnk3oGUPdEPkYq`
- **File group** `admin:active:admin:Administrator group`


#### Using `ImageImport` service provider to import images in the project from exchange folder
Install [ImageMagick](https://imagemagick.org/script/download.php):
  - **linux** the `convert` and `identify` commands should be installed in the `/usr/bin` directory
  - **mac** the `convert` and `identify` commands should be installed in the `/usr/bin` directory
  - **windows** the default version is 7.1.0, so the `convert` and `identify` commands should be installed in the `C:/Programs/ImageMagick-7.1.0` directory
  
  The default paths for the `convert` and `identify` commands can be overwritten in the configuration file `ocr4all/workspace/.ocr4all`

#### Using ocr-d processors
- Enable / Start docker
  - `systemctl enable docker`
  - `systemctl start docker`
- Fetch the ocr-d Docker image (optional, since will be done automatically when using am ocr-d processor for first time)
  - `docker pull ocrd/all:maximum`
- Install models in `ocr4all/opt/ocr-d/resources` (see [ocr-d resource list](https://github.com/OCR-D/core/blob/master/ocrd/ocrd/resource_list.yml))
  - **Calamari recognize** download desired [models](https://github.com/Calamari-OCR/calamari_models/releases/tag/1.1) in subfolder `ocrd-calamari-recognize`
  - **Tesserocr recognize** download desired models  in subfolder `ocrd-tesserocr-recognize`

## API 
### API documentation
The Swagger UI for the API documentation can be accessed under `http://localhost:9090/api/doc/swagger-ui/index.html` while `ocr4all-app` is running

### Example
An example of using the API with the desktop, api, documentation and development profiles.
```
instance
Method: GET
URL: http://localhost:9090/api/v1.0/instance

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
"id": "de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.preprocessing.provider.json.JsonCISOcropyBinarize",
"parent-snapshot": {"track": []},
"label": "cis binarize default",
"description": "ocr-d cis ocropy binarize default"
}

olr: Segment region
Method: POST
URL: http://localhost:9090/api/v1.0/spi/olr/schedule/project_01/sandbox_01
Body:
{
"id": "de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.olr.provider.json.JsonTesserocrSegmentRegion",
"parent-snapshot": {"track": [1]},
"label": "tesserocr segment region default",
"description": "ocr-d tesserocr segment region default"
}

olr: Segment line

Method: POST
URL: http://localhost:9090/api/v1.0/spi/olr/schedule/project_01/sandbox_01
Body:
{
"id": "de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.olr.provider.json.JsonTesserocrSegmentLine",
"parent-snapshot": {"track": [1,1]},
"label": "tesserocr segment line default",
"description": "ocr-d tesserocr segment line default"
}

ocr: Calamari recognize
Method: POST
URL: http://localhost:9090/api/v1.0/spi/ocr/schedule/project_01/sandbox_01
Body:
{
"id": "de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.ocr.provider.json.JsonCalamariRecognize",
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
"id": "de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.ocr.provider.json.JsonTesserocrRecognize",
"selects": [{"argument": "model", "values": ["deu", "frk"]}],
"parent-snapshot": {"track": [1,1,1]},
"label": "Tesserocr models",
"description": "ocr-d Tesserocr models deu + frk"
}
```

Results will be available in the following directories:
- **Calamari recognize** `ocr4all/workspace/projects/project_01/sandboxes/sandbox_01/snapshots/derived/1/derived/1/derived/1/derived/1/sandbox`
- **Tesserocr recognize** `ocr4all/workspace/projects/project_01/sandboxes/sandbox_01/snapshots/derived/1/derived/1/derived/1/derived/2/sandbox`
