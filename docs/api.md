# API

## Take Photos

```
POST /photos
```

Note: This will take a series of 3 photos.

## List Photos

```
GET /photos

[
  { "filename": "1505137428.jpg", "thumbnail": "thumbnails/1505137428.jpg" },
  { "filename": "1505137436.jpg", "thumbnail": "thumbnails/1505137436.jpg" },
  { "filename": "1505137445.jpg", "thumbnail": "thumbnails/1505137445.jpg" }
]
```

## Get Photo

```
GET /photos/:filename
```

NOTE: Returns a JPG. You can also get a thumbnail, e.g. `/photos/thumbnails/1505137428.jpg`.

## Print a Photo

```
POST /photos/:filename/prints
```