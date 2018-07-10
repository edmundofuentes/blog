Edmundo Fuentes' Blog
=====================

A statically-generated blog for my random entries and notes-to-self about programming and finance engineering.
Powered by [Sculpin](http://sculpin.io). Free hosting by [Netlify](https://www.netlify.com).

Install
-------

```bash
$ composer install
```

**UPDATE:** The npm version of the cli does _not_ work on Node 10. Apparently this cli version is
deprecated, but it still appears in their docs. You should now use their [new tool(https://github.com/netlify/netlifyctl)

```bash 
brew tap netlify/netlifyctl
brew install netlifyctl
```

Development Build
-----

```bash
php vendor/bin/sculpin generate --watch --server
```

The newly generated blog is now accessible at `http://localhost:8000/`.


Optionally, use `./run.sh`


Generating Production Builds
----------------------------

When `--env=prod` is specified, the site will be generated in `output_prod/`. This
is the location of your production build.

```bash
php vendor/bin/sculpin generate --env=prod
```


Publish
-------


Using Netlify, we publish

```bash
netlifyctl deploy -P output_prod
```

Optionally, use `./publish.sh` to generate a production build and deploy it to Netlify.