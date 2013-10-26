
###
  File: simpleTable.coffee
  Author: Davide Griffon

  Simple jQuery plugin to create dynamic ajax tables
  simpleTable is open-sourced via the MIT license.
  See https://github.com/griffosx/simpleTable
###


(($) ->
  $.fn.simpleTable = (options) ->

    # display a simple hourglass when waiting for ajax response
    showHourglass = ->
      tableWidth = $("##{settings["tableId"]}").width()
      hourglass = $("<tr/>").append($("<td/>",
        colspan: settings["columns"].length
        style: "padding-left: #{(tableWidth / 2 - 50)}px!important"
      ).append($("<div/>",
        class: "simpleTableHouglass"
        html: settings["textOnWait"]
      )))
      $("##{settings["tableId"]} tbody").append hourglass


    # hide the hourglass when the response arrives
    hideHourglass = ->
      $("##{settings["tableId"]} tbody").empty() # remove hourglass


    # simpleTable creates automatically a section where is possible to filter the results
    initSearchSection = ->
      searchable = settings["searchFields"].length > 0 # if table supports filters
      showSearch = $("<div/>",
        class: "simpleTableShowHideSearchOptions"
        html: settings["textShowHideSearchSection"]
        style: "display: #{(if searchable then "block" else "none")}"
      )
      searchWrapper = $("<div/>", class: "simpleTableSearchWrapper", style: "display: none")
      searchForm = $("<form/>", onsubmit: "return false") # prevent form submit on enter keypress
      searchHtmlTable = $("<table/>")

      # show/hide search options
      showSearch.click ->
        searchWrapper.toggle()

      # add search filters
      for fieldSettings in settings["searchFields"]
        tr = $("<tr/>")
        tr.append $("<td/>", html: "#{fieldSettings["title"]}:")
        tr.append $("<td/>", html: fieldSettings["htmlElement"])
        searchHtmlTable.append tr

      # add hidden search filters if present
      for key of settings["hiddenSearchFields"]
        value = settings["hiddenSearchFields"][key]
        field = $("<input/>", name: key, type: "hidden", value: value)
        searchHtmlTable.append field

      # if limitResult option is enabled, fromRow and toRow inputs are added automatically
      if settings["limitResult"]
        fromRow = $("<input/>", name: "fromRow", type: "text", value: "")
        tr = $("<tr/>")
        tr.append $("<td/>", html: settings["textFromRow"])
        tr.append $("<td/>", html: fromRow.attr("type", "text"))
        searchHtmlTable.append tr
        toRow = $("<input/>", name: "toRow", type: "text", value: "")
        tr = $("<tr/>")
        tr.append $("<td/>", html: settings["textToRow"])
        tr.append $("<td/>", html: toRow.attr("type", "text"))
        searchHtmlTable.append tr

      # add filters to wrapper
      searchForm.append searchHtmlTable
      searchWrapper.append searchForm

      # add search and clear button to wrapper
      searchButton = $("<div/>", html: settings["textSerchButton"], class: "simpleTableButton")
      searchButton.click redrawTable
      clearButton = $("<div/>", html: settings["textClearButton"], class: "simpleTableButton", style: "margin-left: 7px")
      clearButton.click ->
        globalWrapper.find("input").val("") # clear all search filters

      searchWrapper.append searchButton
      searchWrapper.append clearButton

      # add wrapper to page
      globalWrapper.append showSearch
      globalWrapper.append searchWrapper

      # add optional element before table if present
      globalWrapper.append settings["extraElementBeforeTable"]


    # fill the thead element properly
    drawHeader = ->
      header = $("<tr/>")
      for columnDefinition in settings["columns"]
        fieldName = columnDefinition["field"]
        title = columnDefinition["column_title"]
        isSortable = not columnDefinition.hasOwnProperty("sortable") or columnDefinition["sortable"] # default is true, false must be explicit
        orderByfield = (if columnDefinition.hasOwnProperty("orderByField") then columnDefinition["orderByField"] else fieldName)
        cssClasses = (if isSortable then "columnSortable " else "") + ("col_#{fieldName}")
        column = $("<th/>", html: title, class: cssClasses, dataOrderBy: orderByfield)
        header.append column

        # set this column as default orderBy if explicitly setted
        if columnDefinition.hasOwnProperty("defaultOrderBy") and columnDefinition["defaultOrderBy"]
          if columnDefinition.hasOwnProperty("defaultOrderByAscDesc")
            setOrderBy(column, columnDefinition["defaultOrderByAscDesc"])
          else
            setOrderBy(column, "asc")

      $("##{settings["tableId"]} thead").append header


    # add an order by to a column
    setOrderBy = (column, ascDesc=null) -> # column must be the th jquery element of the column
      newOrderBy = column.attr("dataOrderBy")
      $("th.columnSortable").removeClass "asc"
      $("th.columnSortable").removeClass "desc"
      if ascDesc
        if ascDesc is "asc"
          settings["orderBy"] = newOrderBy
          column.addClass "asc"
        else
          settings["orderBy"] = "-#{newOrderBy}"
          column.addClass "desc"
      else
        if settings["orderBy"] is newOrderBy
          settings["orderBy"] = "-#{settings["orderBy"]}"
          column.addClass "desc"
        else
          settings["orderBy"] = newOrderBy
          column.addClass "asc"


    # add click-bindings to columns
    addOrderBys = ->
      $("th.columnSortable").each ->
        $(@).click ->
          setOrderBy($(@))
          redrawTable()


    # initialization of the table
    initTable = ->
      htmlTable = $("<table/>", id: settings["tableId"], class: settings["tableCssClass"])
      htmlTable.append $("<thead/>")
      htmlTable.append $("<tbody/>")
      htmlTable.css("width", settings["tableWidth"])
      globalWrapper.append htmlTable
      drawHeader()
      addOrderBys()


    # redraw the content of the table
    redrawTable = ->
      $("##{settings["tableId"]} tbody tr").remove() # remove old elements

      # disable old resizable table. Needed to prevent unexpected results
      $("##{settings["tableId"]}").colResizable(disable: true) if settings["resizable"]
      url = settings["ajaxUrl"]
      payload = if settings["orderBy"] then "orderBy=#{settings["orderBy"]}&" else ""
      payload += globalWrapper.find("form").serialize()
      showHourglass()

      # retrieving data from ajax
      $.ajax
        url: url
        dataType: settings["dataType"]
        data: payload
        timeout: settings["timeout"]

        success: (data, textStatus, jqXHR) ->
          data = settings["dataParser"](data) # execute additional custom function if present
          hideHourglass()
          if data.length is 0
            drawEmptyTable settings["textIfEmpty"]
          else
            drawRows data
            if settings["resizable"]
              $("##{settings["tableId"]}").colResizable(hoverCursor: "col-resize", dragCursor: "col-resize")

          settings["onTableCreated"](data, settings["tableId"]) # execute additional function if present

        error: (jqXHR, textStatus, errorThrown) ->
          hideHourglass()
          drawEmptyTable settings["textOnError"]


    # draw all rows of the table. rows must be a list of dictionaries
    drawRows = (rows) ->
      for row in rows
        htmlRow = $("<tr/>")
        for columnDefinition in settings["columns"]
          fieldName = columnDefinition["field"]
          rendered_field = if columnDefinition.hasOwnProperty("renderer") then columnDefinition["renderer"](row) else row[fieldName]
          htmlColumn = $("<td/>", html: rendered_field, class: "col_#{fieldName}")
          htmlColumn.attr("title", columnDefinition["titleRenderer"](row)) if columnDefinition.hasOwnProperty("titleRenderer")
          htmlRow.append htmlColumn

        $("##{settings["tableId"]} tbody").append htmlRow


    # draw error or an empty table
    drawEmptyTable = (text) ->
      htmlRow = $("<tr/>")
      htmlRow.append $("<td/>", colspan: settings["columns"].length, html: text)
      $("##{settings["tableId"]} tbody").append htmlRow


    # default configuration
    defaults =
      dataType: "json"                               # datatipe returned from $.ajax
      timeout: 60000                                 # timeout of the $.ajax call
      ajaxUrl: ""                                    # url called by $.ajax
      limitResult: false                             # if true, `fromRow` and `toRow` search fields are automatically added to the search section
      columns: []                                    # definitions of columns
      tableId: "simpleTable_#{(new Date).getTime()}" # unique id
      tableWidth: "100%"                             # total width of the table. all valid css can be used (400px, auto...)
      tableCssClass: "simpleTable"                   # the css class assigned
      extraElementBeforeTable: ""                    # dom element inserted after search section and before table, optional
      searchFields: []                               # definitions of the search fields
      hiddenSearchFields: {}                         # hidden search fields automatically added
      resizable: true                                # determines whether columns are resizables
      # optional function executed when ajax reponse arrive. Useful if data manipulation is needed before rendering
      dataParser: (data) -> data
      # optional function executed each time table is rendered
      onTableCreated: (data, tableId) ->
      # following some default text used by the table
      textShowHideSearchSection: "Show/hide search options"
      textOnWait: "Wait please"
      textFromRow: "From row:"
      textToRow: "To wor:"
      textSerchButton: "Search"
      textClearButton: "Clear filters"
      textIfEmpty: "Table is empty"
      textOnError: "Error"

    settings = $.extend({}, defaults, options)
    globalWrapper = @

    # return the plugin
    @each ->
      initSearchSection()
      initTable()
      redrawTable()
) jQuery
