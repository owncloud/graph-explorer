# GRAPI Explorer

This is a Kopano fork of the Microsoft Graph Explorer so it can be used with a self hosted Kopano GRAPI.

## Technology.

The Graph Explorer is written in [TypeScript](https://www.typescriptlang.org/) and powered by:
* [Angular 4](https://angular.io/)
* [Office Fabric](https://dev.office.com/fabric)
* [Microsoft Web Framework](https://getmwf.com/)

## Running the explorer locally

* `npm install` to install project dependencies. `npm` is installed by default with [Node.js](https://nodejs.org/).
* `npm start` starts the TypeScript compiler in watch mode and the local server. It should open your browser automatically with the Graph Explorer at [http://localhost:3000/](http://localhost:3000).

## Configuration

* You will need to setup Konnect to allow your explorer as a trusted web client. You don't need a client secret since the explorer is a single page application. Rename `secrets.sample.js` to `secrects.js` and `config.sample.js` to `config.js` and insert your client ID, Iss and URL to GRAPI.

## Copyright

Copyright (c) 2017 Microsoft. All rights reserved.
Copyright (c) 2019 Kopano b.v.
