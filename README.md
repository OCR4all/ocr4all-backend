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
* `Java 11`
* `mvn`

### Download
Clone this repository recursively
```
git clone --recurse-submodules --remote-submodules git@github.com:OCR4all/ocr4all-backend.git
```

### Build 
To build and run the `ocr4all-app`, either use your favorite IDE or create a JAR through your terminal:

#### IDE
- installing [Spring Tools](https://spring.io/tools) is heavily recommended
- import all contained submodules as Maven project in the above-mentioned sequence in your IDE
- start the application using `Spring Tools` in `Boot Dashboard`

#### Terminal
- run `mvn clean install` in following projects in this order 
  1. ocr4all-app-persistence
  2. ocr4all-app-spi
  3. ocr4all-app-ocrd-spi
- in the project `ocr4all-app` run `mvn clean package` 

### Application

Start the application in the project `ocr4all-app` with `java -jar target/ocr4all-app-1.0-SNAPSHOT.jar`.

#### Defaults

The defaults for the application are defined in the file `src/main/resources/application.ymly` of the project `ocr4all-app`. The server HTTP port is 8080. Several profiles are defined that can be used to control the behaviour of the application:
- **desktop** disables security and stores the application data in the user's home directory `${user.home}/ocr4all`.
- **server** enables security and stores the application data in the system directory `/srv/ocr4all`.
- **api** activates the RESTful API interface
- **documentation** activates the RESTful API documentation with Swagger 2 
- **development** uses server HTTP port 9090, provides more logging information and stores application data in the user's home directory `${user.home}/ocr4all`.

The development version uses the following profiles by default: server, api, documentation and development.

#### Security
Authentication/authorisation is activated in server profile and deactivated in desktop profile.

Authentication/authorisation is configured in the following files in the `ocr4all/workspace/.ocr4all` folder (see below for an example setup): users, passwords and groups.
After authentication in the application with administrative rights, the API can be used to manage users, passwords and groups.

If the application uses server profile and, development profile is enabled and/or the application property `ocr4all.application.security.administrator.create` is set to `true`, a default administrator user is created with the login `admin` and password `ocr4all` if no administrator user exists.

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
The Swagger UI for the API documentation can be accessed under `http://localhost:9090/api/doc/swagger-ui/` while `ocr4all-app` is running

### Example
An example using the API
```
instance
Method: GET
URL: http://localhost:9090/api/v1.0/instance

login
Method: POST
URL: http://localhost:9090/api/v1.0/login
Body:
{
“username”: “test”,
“password”: “pico”
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
“id”: “de.uniwuerzburg.zpd.ocr4all.application.core.spi.imp.provider.ImageImport”,
“strings”: [
{“argument”: “source-folder”, “value”: “images”}
],
“selects”: [
{“argument”: “image-formats”, “values”: [“tif”]}
]
}

Create a workflow
Method: GET
URL: http://localhost:9090/api/v1.0/workflow/create/project_01?id=ws_01

Launch the workflow
Method: POST
URL: http://localhost:9090/api/v1.0/spi/launcher/schedule/project_01/ws_01
Body:
{
“id”: “de.uniwuerzburg.zpd.ocr4all.application.core.spi.launcher.provider.WorkflowLauncher”,
“images”: [
{“argument”: “images”, “values”: [1,2,3,4,5,6]}
],
“name”: “launcher default with images”,
“description”: “description launcher default with images”
}
```

* Using ocr-d processors
```
preprocessing: Binarize
Method: POST
URL: http://localhost:9090/api/v1.0/spi/preprocessing/schedule/project_01/ws_01
Body:
{
“id”: “de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.preprocessing.provider.CISOcropyBinarize”,
“parent-snapshot”: {“track”: []},
“name”: “cis binarize default”,
“description”: “ocr-d cis ocropy binarize default”
}

olr: Segment region
Method: POST
URL: http://localhost:9090/api/v1.0/spi/olr/schedule/project_01/ws_01
Body:
{
“id”: “de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.olr.provider.TesserocrSegmentRegion”,
“parent-snapshot”: {“track”: [1]},
“name”: “tesserocr segment region default”,
“description”: “ocr-d tesserocr segment region default”
}

olr: Segment line

Method: POST
URL: http://localhost:9090/api/v1.0/spi/olr/schedule/project_01/ws_01
Body:
{
“id”: “de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.olr.provider.TesserocrSegmentLine”,
“parent-snapshot”: {“track”: [1,1]},
“name”: “tesserocr segment line default”,
“description”: “ocr-d tesserocr segment line default”
}

ocr: Calamari recognize
Method: POST
URL: http://localhost:9090/api/v1.0/spi/ocr/schedule/project_01/ws_01
Body:
{
“id”: “de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.ocr.provider.CalamariRecognize”,
“parent-snapshot”: {“track”: [1,1,1]},
“name”: “Calamari default”,
“description”: “ocr-d Calamari default”
}

ocr: Tesserocr recognize
Method: POST
URL: http://localhost:9090/api/v1.0/spi/ocr/schedule/project_01/ws_01
Body:
{
“id”: “de.uniwuerzburg.zpd.ocr4all.application.ocrd.spi.ocr.provider.TesserocrRecognize”,
"selects": [{"argument": "models", "values": ["deu", "frk"]}],
“parent-snapshot”: {“track”: [1,1,1]},
“name”: “Tesserocr models”,
“description”: “ocr-d Tesserocr models”
}
```

Results will be available in the directories:
- **Calamari recognize** `ocr4all/workspace/projects/project_01/workflows/ws_01/snapshots/derived/1/derived/1/derived/1/derived/1/sandbox`
- **Tesserocr recognize** `ocr4all/workspace/projects/project_01/workflows/ws_01/snapshots/derived/1/derived/1/derived/1/derived/2/sandbox`
