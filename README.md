Edmundo Fuentes' Blog
=====================

A skeleton for a Sculpin based blog.

Powered by [Sculpin](http://sculpin.io).

Install
-------

```bash
$ composer install
```

[Install Netlify command line tools](https://www.netlify.com/docs/cli/) using `npm`, the node package manager.

```bash
npm install netlify-cli g
```

**UPDATE:** Netlify is buggy as fuck. The npm version of the cli does _not_ work on Node 10. Apparently this cli version is
deprecated, but it still appers in their docs. You should now use the `netlifyctl` tool.

https://github.com/netlify/netlifyctl

```bash 
brew tap netlify/netlifyctl
brew install netlifyctl
```

Development Build
-----

    php vendor/bin/sculpin generate --watch --server

The newly generated blog is now accessible at `http://localhost:8000/`.


Optionally, use `./run.sh`


Generating Production Builds
----------------------------

When `--env=prod` is specified, the site will be generated in `output_prod/`. This
is the location of your production build.

    php vendor/bin/sculpin generate --env=prod


Publish
-------

Using Netlify




Optionally, use `./publish.sh` to generate a production build and deploy it to Netlify.