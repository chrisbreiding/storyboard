## Storyboard

A read-only client for Pivotal Tracker optimized for use on a status board.

### Prerequisites

Install:

* node
* npm

Run:

```
npm install
```

### Running locally

Run:

```
npm run prod
```

then go to [http://localhost:8081](http://localhost:8081)

### Developing

Run:

```
npm run dev
```

which will:

* compile CoffeeScript, SCSS, and Handlebars(.hbs) files on save
* run a server at [http://localhost:8080](http://localhost:8080)

### Deploying

Run:

```
npm run deploy
```

which will:

* compile and optimize scripts and stylesheets
* put only the relevant files into the `_build` directory
* checkout the `_build` directory into the `gh-pages` branch
* **force push** the `gh-pages` branch to the remote
