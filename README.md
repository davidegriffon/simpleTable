# Disclamer
This is an old unmaintained repository! This project was only an experiment I made in order to learn Coffeecript.

# SimpleTable

A simple jQuery plugin to create dynamic ajax tables

## Usage

In order to use SimpleTable you need to include some files in your page:

Jquery  (version 1.9 or above temporary ***NOT*** supported)
```
<script type="text/javascript" src="http://code.jquery.com/jquery-1.8.3.min.js"></script>
```

colResizable jQuery [plugin](http://quocity.com/colresizable/)
```
<script type="text/javascript" src="/static/js/colResizable-1.3.min.js"></script>
```

simpleTable plugin itself
```
<script type="text/javascript" src="/static/js/simpleTable.js"></script>
```

simpleTable default css or a customized one
```
<link rel="stylesheet" href="/static/css/simpleTable.css"/>
```

Then you have to define a container. (typically an html div where the table will be appended)

```<div id="tableWrapper"></div>```

Then you can easily define your table as
```
$("#tableWrapper").simpleTable({
    tableId: "someId",
    ajaxUrl: "/ajax/cities", // ajax automatically called by the table to retrieve the data
    // here you define all the columns the table should display
    columns: [
        {
            "column_title": "City",
            "field": "name",
            "defaultOrderBy": true,
            "defaultOrderByAscDesc": "desc"
        },
        {
            "column_title": "Country",
            "field": "country"
        },
        {
            "column_title": "Population",
            "field": "population",
            "renderer": populationRenderer // a javascript callable
        },
        {
            "column_title": "Time zone",
            "field": "timezone",
            "sortable": false // if false this column won't be sortable
        }
    ],
    // search filters automatically added to the table
    searchFields: [
        {"title": "Name", "htmlElement": nameFilter},
        {"title": "Country", "htmlElement": countryFilter}
    ],
});
```

More detailed doumentation soon.
See flaskExample to obtain a runnable example (you need Python and Flask installed)
