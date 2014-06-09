## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

<%!
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
%>

${ commonheader(_('Search'), "search", user, "80px") | n,unicode }

<script type="text/javascript">
  if (window.location.hash != "") {
    if (window.location.hash.indexOf("collection") > -1) {
      location.href = "/search/?" + window.location.hash.substr(1);
    }
  }
</script>

<div class="search-bar">
  <div class="pull-right" style="padding-right:50px">
    % if user.is_superuser:
      <button type="button" title="${ _('Edit') }" rel="tooltip" data-placement="bottom" data-bind="click: toggleEditing, css: {'btn': true, 'btn-inverse': isEditing}"><i class="fa fa-pencil"></i></button>
      <button type="button" title="${ _('Save') }" rel="tooltip" data-placement="bottom" data-loading-text="${ _("Saving...") }" data-bind="click: save, css: {'btn': true}"><i class="fa fa-save"></i></button>
      <button type="button" title="${ _('Settings') }" rel="tooltip" data-placement="bottom" data-toggle="modal" data-target="#settingsDemiModal"
          data-bind="css: {'btn': true}">
        <i class="fa fa-cog"></i>
      </button>
    % endif
      <button type="button" title="${ _('Share') }" rel="tooltip" data-placement="bottom" data-bind="click: showShareModal, css: {'btn': true}"><i class="fa fa-link"></i></button>
    % if user.is_superuser:
      &nbsp;&nbsp;&nbsp;
      <a class="btn" href="${ url('search:new_search') }" title="${ _('New') }" rel="tooltip" data-placement="bottom" data-bind="css: {'btn': true}"><i class="fa fa-file-o"></i></a>
      <a class="btn" href="${ url('search:admin_collections') }" title="${ _('Collections') }" rel="tooltip" data-placement="bottom" data-bind="css: {'btn': true}"><i class="fa fa-tags"></i></a>
    % endif
  </div>

  <form data-bind="visible: $root.isEditing() && columns().length == 0">
    ${ _('Select a search index') }
    <!-- ko if: columns().length == 0 -->
    <select data-bind="options: $root.initial.collections, value: $root.collection.name">
    </select>
    <!-- /ko -->
  </form>

  <form class="form-search" style="margin: 0" data-bind="submit: searchBtn, visible: columns().length != 0">
    <strong>${_("Search")}</strong>
    <div class="input-append">
      <div class="selectMask">
        <span
            data-bind="editable: collection.label, editableOptions: {enabled: $root.isEditing(), placement: 'right'}">
        </span>
      </div>

      <span data-bind="foreach: query.qs">
        <input data-bind="clearable: q" maxlength="4096" type="text" class="search-query input-xlarge">
        <!-- ko if: $index() >= 1 -->
        <a class="btn" href="javascript:void(0)" data-bind="click: $root.query.removeQ"><i class="fa fa-minus"></i></a>
        <!-- /ko -->
      </span>

      <a class="btn" href="javascript:void(0)" data-bind="click: $root.query.addQ"><i class="fa fa-plus"></i></a>

      <button type="submit" id="search-btn" class="btn btn-inverse" style="margin-left:10px"><i class="fa fa-search"></i></button>
    </div>
  </form>
</div>

<div class="card card-toolbar" data-bind="slideVisible: isEditing">
  <div style="float: left">
    <div class="toolbar-label">${_('LAYOUT')}</div>
    <a href="javascript: oneThirdLeftLayout()" onmouseover="viewModel.previewColumns('oneThirdLeft')" onmouseout="viewModel.previewColumns('')">
      <div class="layout-container">
        <div class="layout-box" style="width: 24px"></div>
        <div class="layout-box" style="width: 72px; margin-left: 4px"></div>
      </div>
    </a>
    <a href="javascript: fullLayout()" onmouseover="viewModel.previewColumns('full')" onmouseout="viewModel.previewColumns('')">
      <div class="layout-container">
        <div class="layout-box" style="width: 100px;"></div>
      </div>
    </a>
    <a data-bind="visible: columns().length == 0" href="javascript: magicLayout(viewModel)" onmouseover="viewModel.previewColumns('magic')" onmouseout="viewModel.previewColumns('')">
      <div class="layout-container">
        <div class="layout-box" style="width: 100px;"><i class="fa fa-magic"></i></div>
      </div>
    </a>
  </div>

  <div style="float: left; margin-left: 20px" data-bind="visible: columns().length > 0">
    <div class="toolbar-label">${_('WIDGETS')}</div>
    <div data-bind="css: { 'draggable-widget': true, 'disabled': !availableDraggableResultset() },
                    draggable: {data: draggableResultset(), isEnabled: availableDraggableResultset,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast'); $root.collection.template.isGridLayout(true); }}}"
         title="${_('Grid Results')}" rel="tooltip" data-placement="top">
         <a data-bind="style: { cursor: $root.availableDraggableResultset() ? 'move' : 'default' }">
                       <i class="fa fa-table"></i>
         </a>
    </div>
    <div data-bind="css: { 'draggable-widget': true, 'disabled': !availableDraggableResultset() },
                    draggable: {data: draggableHtmlResultset(),
                    isEnabled: availableDraggableResultset,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)}); $root.collection.template.isGridLayout(false); }}}"
         title="${_('HTML Results')}" rel="tooltip" data-placement="top">
         <a data-bind="style: { cursor: $root.availableDraggableResultset() ? 'move' : 'default' }">
                       <i class="fa fa-code"></i>
         </a>
    </div>
    <div data-bind="css: { 'draggable-widget': true, 'disabled': !availableDraggableChart() },
                    draggable: {data: draggableFacet(), isEnabled: availableDraggableChart,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Text Facet')}" rel="tooltip" data-placement="top">
         <a data-bind="style: { cursor: $root.availableDraggableChart() ? 'move' : 'default' }">
                       <i class="fa fa-sort-amount-asc"></i>
         </a>
    </div>
    <div data-bind="css: { 'draggable-widget': true, 'disabled': !availableDraggableChart() },
                    draggable: {data: draggablePie(), isEnabled: availableDraggableChart,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Pie Chart')}" rel="tooltip" data-placement="top">
         <a data-bind="style: { cursor: $root.availableDraggableChart() ? 'move' : 'default' }">
                       <i class="hcha hcha-pie-chart"></i>
         </a>
    </div>
    <!-- <div class="draggable-widget" data-bind="draggable: {data: draggableHit(), options: {'start': function(event, ui){$('.card-body').slideUp('fast');}, 'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}" title="${_('Hit Count')}" rel="tooltip" data-placement="top"><a data-bind="attr: {href: $root.availableDraggableResultset()}, css: {'btn-inverse': ! $root.availableDraggableResultset() }, style: { cursor: $root.availableDraggableResultset() ? 'move' : 'default' }"><i class="fa fa-tachometer"></i></a></div> -->
    <div data-bind="css: { 'draggable-widget': true, 'disabled': !availableDraggableChart() },
                    draggable: {data: draggableBar(), isEnabled: availableDraggableChart,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Bar Chart')}" rel="tooltip" data-placement="top">
         <a data-bind="style: { cursor: $root.availableDraggableChart() ? 'move' : 'default' }">
                       <i class="hcha hcha-bar-chart"></i>
         </a>
    </div>
    <div data-bind="css: { 'draggable-widget': true, 'disabled': !availableDraggableNumbers() },
                    draggable: {data: draggableLine(), isEnabled: availableDraggableNumbers,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Line Chart')}" rel="tooltip" data-placement="top">
         <a data-bind="style: { cursor: $root.availableDraggableNumbers() ? 'move' : 'default' }">
                       <i class="hcha hcha-line-chart"></i>
         </a>
    </div>
    <div data-bind="css: { 'draggable-widget': true, 'disabled': !availableDraggableHistogram() },
                    draggable: {data: draggableHistogram(), isEnabled: availableDraggableHistogram,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Timeline')}" rel="tooltip" data-placement="top">
         <a data-bind="style: { cursor: $root.availableDraggableHistogram() ? 'move' : 'default' }">
                       <i class="hcha hcha-timeline-chart"></i>
         </a>
    </div>
    <div data-bind="css: { 'draggable-widget': true, 'disabled': !availableDraggableFilter() },
                    draggable: {data: draggableFilter(), isEnabled: availableDraggableFilter,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Filter Bar')}" rel="tooltip" data-placement="top">
         <a data-bind="style: { cursor: $root.availableDraggableFilter() ? 'move' : 'default' }">
                       <i class="fa fa-filter"></i>
         </a>
    </div>
    <div data-bind="css: { 'draggable-widget': true, 'disabled': !availableDraggableChart() },
                    draggable: {data: draggableMap(), isEnabled: availableDraggableChart,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Map')}" rel="tooltip" data-placement="top">
         <a data-bind="style: { cursor: $root.availableDraggableChart() ? 'move' : 'default' }">
                       <i class="hcha hcha-map-chart"></i>
         </a>
   </div>
  </div>
  <div class="clearfix"></div>
</div>

<div id="emptyDashboard" data-bind="fadeVisible: !isEditing() && columns().length == 0">
  <div style="float:left; padding-top: 90px; margin-right: 20px; text-align: center; width: 260px">${ _('Click on the pencil to get started with your dashboard!') }</div>
  <img src="/search/static/art/hint_arrow.png" />
</div>

<div id="emptyDashboardEditing" data-bind="fadeVisible: isEditing() && columns().length == 0 && previewColumns() == ''">
  <div style="float:right; padding-top: 90px; margin-left: 20px; text-align: center; width: 260px">${ _('Pick an index and Click on a layout to start your dashboard!') }</div>
  <img src="/search/static/art/hint_arrow_horiz_flipped.png" />
</div>



<div data-bind="visible: isEditing() && previewColumns() != '' && columns().length == 0, css:{'with-top-margin': isEditing()}">
  <div class="container-fluid">
    <div class="row-fluid" data-bind="visible: previewColumns() == 'oneThirdLeft'">
      <div class="span3 preview-row"></div>
      <div class="span9 preview-row"></div>
    </div>
    <div class="row-fluid" data-bind="visible: previewColumns() == 'full'">
      <div class="span12 preview-row">
      </div>
    </div>
    <div class="row-fluid" data-bind="visible: previewColumns() == 'magic'">
      <div class="span12 preview-row">
        <div style="text-align: center; color:#EEE; font-size: 180px; margin-top: 80px">
          <i class="fa fa-magic"></i>
        </div>
      </div>
    </div>
  </div>
</div>

<div data-bind="css: {'dashboard': true, 'with-top-margin': isEditing()}">
  <div class="container-fluid">
    <div class="row-fluid" data-bind="template: { name: 'column-template', foreach: columns}">
    </div>
    <div class="clearfix"></div>
  </div>
</div>

<script type="text/html" id="column-template">
  <div data-bind="css: klass">
    <div class="container-fluid" data-bind="visible: $root.isEditing">
      <div data-bind="click: function(){$data.addEmptyRow(true)}, css: {'add-row': true, 'is-editing': $root.isEditing}, sortable: { data: drops, isEnabled: $root.isEditing, 'afterMove': function(event){var widget=event.item; var _r = $data.addEmptyRow(true); _r.addWidget(widget);$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)}); if ($root.collection.getFacetById(widget.id()) == null) { showAddFacetDemiModal(widget); } viewModel.search()}, options: {'placeholder': 'add-row-highlight', 'greedy': true, 'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"></div>
    </div>
    <div data-bind="template: { name: 'row-template', foreach: rows}">
    </div>
    <div class="container-fluid" data-bind="visible: $root.isEditing">
      <div data-bind="click: function(){$data.addEmptyRow()}, css: {'add-row': true, 'is-editing': $root.isEditing}, sortable: { data: drops, isEnabled: $root.isEditing, 'afterMove': function(event){var widget=event.item; var _r = $data.addEmptyRow(); _r.addWidget(widget);$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)}); if ($root.collection.getFacetById(widget.id()) == null) { showAddFacetDemiModal(widget); } viewModel.search()}, options: {'placeholder': 'add-row-highlight', 'greedy': true, 'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"></div>
    </div>
  </div>
</script>

<script type="text/html" id="row-template">
  <div class="emptyRow" data-bind="visible: widgets().length == 0 && $index() == 0 && $root.isEditing() && $parent.size() > 4 && $parent.rows().length == 1">
    <img src="/search/static/art/hint_arrow_flipped.png" style="float:left; margin-right: 10px"/>
    <div style="float:left; text-align: center; width: 260px">${_('Drag any of the widgets inside your empty row')}</div>
    <div class="clearfix"></div>
  </div>
  <div class="container-fluid">
    <div class="row-header" data-bind="visible: $root.isEditing">
      <span class="muted">${_('Row')}</span>
      <div style="display: inline; margin-left: 60px">
        <a href="javascript:void(0)" data-bind="visible: $index()<$parent.rows().length-1, click: function(){moveDown($parent, this)}"><i class="fa fa-chevron-down"></i></a>
        <a href="javascript:void(0)" data-bind="visible: $index()>0, click: function(){moveUp($parent, this)}"><i class="fa fa-chevron-up"></i></a>
        <a href="javascript:void(0)" data-bind="visible: $parent.rows().length > 1, click: function(){remove($parent, this)}"><i class="fa fa-times"></i></a>
      </div>
    </div>
    <div data-bind="css: {'row-fluid': true, 'row-container':true, 'is-editing': $root.isEditing},
        sortable: { template: 'widget-template', data: widgets, isEnabled: $root.isEditing,
        options: {'handle': '.move-widget', 'opacity': 0.7, 'placeholder': 'row-highlight', 'greedy': true,
            'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});},
            'helper': function(event){lastWindowScrollPosition = $(window).scrollTop(); $('.card-body').slideUp('fast'); var _par = $('<div>');_par.addClass('card card-widget');var _title = $('<h2>');_title.addClass('card-heading simple');_title.text($(event.toElement).text());_title.appendTo(_par);_par.height(80);_par.width(180);return _par;}},
            dragged: function(widget){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});showAddFacetDemiModal(widget);viewModel.search()}}">
    </div>
  </div>
</script>

<script type="text/html" id="widget-template">
  <div data-bind="attr: {'id': 'wdg_'+ id(),}, css: klass">
    <h2 class="card-heading simple">
      <span data-bind="visible: $root.isEditing">
        <a href="javascript:void(0)" class="move-widget"><i class="fa fa-arrows"></i></a>
        <a href="javascript:void(0)" data-bind="click: compress, visible: size() > 1"><i class="fa fa-step-backward"></i></a>
        <a href="javascript:void(0)" data-bind="click: expand, visible: size() < 12"><i class="fa fa-step-forward"></i></a>
        &nbsp;
      </span>
      <span data-bind="with: $root.collection.getFacetById(id())">
        <span data-bind="editable: label, editableOptions: {enabled: $root.isEditing(), placement: 'right'}"></span>
      </span>
      <!-- ko ifnot: $root.collection.getFacetById(id()) -->
        <span data-bind="editable: name, editableOptions: {enabled: $root.isEditing(), placement: 'right'}"></span>
      <!-- /ko -->
      <div class="inline pull-right" data-bind="visible: $root.isEditing">
        <a href="javascript:void(0)" data-bind="click: function(){remove($parent, this)}"><i class="fa fa-times"></i></a>
      </div>
    </h2>
    <div class="card-body" style="padding: 5px;">
      <div data-bind="template: { name: function() { return widgetType(); }}" class="widget-main-section"></div>
    </div>
  </div>
</script>

<script type="text/html" id="empty-widget">
  ${ _('This is an empty widget.')}
</script>


<script type="text/html" id="hit-widget">
  <!-- ko if: $root.getFacetFromQuery(id()) -->
  <div class="row-fluid" data-bind="with: $root.getFacetFromQuery(id())">
    <div data-bind="visible: $root.isEditing, with: $root.collection.getFacetById($parent.id())" style="margin-bottom: 20px">
      ${ _('Label') }: <input type="text" data-bind="value: label" />
    </div>

    <span data-bind="text: query" />: <span data-bind="text: count" />
  </div>
  <!-- /ko -->
</script>

<script type="text/html" id="facet-toggle">
    <!-- ko if: type() == 'range' -->
      <!-- ko ifnot: properties.isDate() -->
        <div class="slider-cnt" data-bind="slider: {start: properties.start, end: properties.end, gap: properties.gap, min: properties.min, max: properties.max}"></div>
      <!-- /ko -->
      <!-- ko if: properties.isDate() -->
        <div data-bind="daterangepicker: {start: properties.start, end: properties.end, gap: properties.gap, min: properties.min, max: properties.max}"></div>
        <br/>
      <!-- /ko -->
    <!-- /ko -->

    <!-- ko if: type() == 'field' -->
      <div class="facet-field-cnt">
        <span class="spinedit-cnt">
          <span class="facet-field-label">${ _('Limit') }</span> <input type="text" class="input-medium" data-bind="spinedit: properties.limit" />
        </span>
      </div>
    <!-- /ko -->

    <a href="javascript: void(0)" title="${ _('Toggle range or field facet') }" class="btn btn-loading" data-bind="visible: properties.canRange, click: $root.collection.toggleRangeFacet" data-loading-text="...">
      <i class="fa" data-bind="css: { 'fa-arrows-h': type() == 'range', 'fa-circle': type() == 'field' }, attr: { title: type() == 'range' ? 'Range' : 'Term' }"></i>
    </a>
    <a href="javascript: void(0)" title="${ _('Toggle sort order') }" class="btn btn-loading" data-bind="click: $root.collection.toggleSortFacet" data-loading-text="...">
      <i class="fa" data-bind="css: { 'fa-caret-down': properties.sort() == 'desc', 'fa-caret-up': properties.sort() == 'asc' }"></i>
    </a>
</script>

<script type="text/html" id="facet-widget">
  <div class="widget-spinner" data-bind="visible: isLoading()">
    <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
    <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
  </div>

  <!-- ko if: $root.getFacetFromQuery(id()) -->
  <div class="row-fluid" data-bind="with: $root.getFacetFromQuery(id())">
    <div data-bind="visible: $root.isEditing, with: $root.collection.getFacetById($parent.id())" style="margin-bottom: 20px">
      <span data-bind="template: { name: 'facet-toggle', afterRender: function(){ $root.getWidgetById($parent.id).isLoading(false); } }">
      </span>
    </div>
    <div data-bind="with: $root.collection.getFacetById($parent.id())">
      <!-- ko if: type() != 'range' -->
        <div data-bind="foreach: $parent.counts">
          <div>
            <a href="javascript: void(0)">
              <!-- ko if: $index() != $parent.properties.limit() -->
                <!-- ko if: ! $data.selected -->
                  <span data-bind="text: $data.value, click: function(){ $root.query.toggleFacet({facet: $data, widget_id: $parent.id()}) }"></span>
                  <span class="counter" data-bind="text: ' (' + $data.count + ')', click: function(){ $root.query.toggleFacet({facet: $data, widget_id: $parent.id()}) }"></span>
                <!-- /ko -->
                <!-- ko if: $data.selected -->
                  <span data-bind="click: function(){ $root.query.toggleFacet({facet: $data, widget_id: $parent.id()}) }">
                    <span data-bind="text: $data.value"></span>
                    <i class="fa fa-times"></i>
                  </span>
                <!-- /ko -->
              <!-- /ko -->
              <!-- ko if: $index() == $parent.properties.limit() -->
                <!-- ko if: $parent.properties.prevLimit == undefined || $parent.properties.prevLimit == $parent.properties.limit() -->
                  <span data-bind="click: function(){ $root.collection.upDownFacetLimit($parent.id(), 'up') }">
                    ${ _('Show more...') }
                  </span>
                <!-- /ko -->
                <!-- ko if: $parent.properties.prevLimit != undefined && $parent.properties.prevLimit != $parent.properties.limit() -->
                  <span data-bind="click: function(){ $root.collection.upDownFacetLimit($parent.id(), 'up') }">
                    ${ _('Show more') }
                  </span>
                  /
                  <span data-bind="click: function(){ $root.collection.upDownFacetLimit($parent.id(), 'down') }">
                    ${ _('less...') }
                  </span>
                </span>
                <!-- /ko -->
              <!-- /ko -->
            </a>
          </div>
        </div>
      <!-- /ko -->
      <!-- ko if: type() == 'range' -->
        <div data-bind="foreach: $parent.counts">
          <div>
            <a href="javascript: void(0)">
              <!-- ko if: ! selected -->
                <span data-bind="click: function(){ $root.query.selectRangeFacet({count: $data.value, widget_id: $parent.id(), from: $data.from, to: $data.to, cat: $data.field}) }">
                  <span data-bind="text: $data.from + ' - ' + $data.to"></span>
                  <span class="counter" data-bind="text: ' (' + $data.value + ')'"></span>
                </span>
              <!-- /ko -->
              <!-- ko if: selected -->
                <span data-bind="click: function(){ $root.query.selectRangeFacet({count: $data.value, widget_id: $parent.id(), from: $data.from, to: $data.to, cat: $data.field}) }">
                  <span data-bind="text: $data.from + ' - ' + $data.to"></span>
                  <i class="fa fa-times"></i>
                </span>
              <!-- /ko -->
            </a>
          </div>
        </div>
      <!-- /ko -->
    </div>
  </div>
  <!-- /ko -->
</script>

<script type="text/html" id="resultset-widget">
  <!-- ko if: $root.collection.template.isGridLayout() -->
    <div style="float:left; margin-right: 10px">
      <div data-bind="visible: ! $root.collection.template.showFieldList()" style="padding-top: 5px; display: inline-block">
        <a href="javascript: void(0)"  data-bind="click: function(){ $root.collection.template.showFieldList(true) }">
          <i class="fa fa-chevron-right"></i>
        </a>
      </div>
    </div>
    <div data-bind="visible: $root.collection.template.showFieldList()" style="float:left; margin-right: 10px; background-color: #F6F6F6; padding: 5px">
      <span data-bind="visible: $root.collection.template.showFieldList()">
        <div>
          <a href="javascript: void(0)" class="pull-right" data-bind="click: function(){ $root.collection.template.showFieldList(false) }">
            <i class="fa fa-chevron-left"></i>
          </a>
          <input type="text" data-bind="clearable: $root.collection.template.fieldsAttributesFilter, valueUpdate:'afterkeydown'" placeholder="${_('Filter fields')}" style="width: 70%; margin-bottom: 10px" />
        </div>
        <div style="margin-bottom: 8px">
          <a href="javascript: void(0)" data-bind="click: function(){$root.collection.template.filteredAttributeFieldsAll(true)}, style: {'font-weight': $root.collection.template.filteredAttributeFieldsAll() ? 'bold': 'normal'}">${_('All')} (<span data-bind="text: $root.collection.template.fieldsAttributes().length"></span>)</a> / <a href="javascript: void(0)" data-bind="click: function(){$root.collection.template.filteredAttributeFieldsAll(false)}, style: {'font-weight': ! $root.collection.template.filteredAttributeFieldsAll() ? 'bold': 'normal'}">${_('Current')} (<span data-bind="text: $root.collection.template.fields().length"></span>)</a>
        </div>
        <div style="border-bottom: 1px solid #CCC; padding-bottom: 4px;">
          <a href="javascript: void(0)" class="btn btn-mini"
            data-bind="click: toggleGridFieldsSelection, css: { 'btn-inverse': $root.collection.template.fields().length > 0 }"
            style="margin-right: 2px;">
            <i class="fa fa-square-o"></i>
          </a>
          <strong>${_('Field Name')}</strong>
        </div>
        <div class="fields-list" data-bind="foreach: $root.collection.template.filteredAttributeFields" style="max-height: 230px; overflow-y: auto; padding-left: 4px">
          <div style="margin-bottom: 3px">
            <input type="checkbox" data-bind="checkedValue: name, checked: $root.collection.template.fieldsSelected" style="margin: 0" />
            <div data-bind="text: name, css:{'field-selector': true, 'hoverable': $root.collection.template.fieldsSelected.indexOf(name()) > -1}, click: highlightColumn"></div>
          </div>
        </div>
        <div data-bind="visible: $root.collection.template.filteredAttributeFields().length == 0" style="padding-left: 4px; padding-top: 5px; font-size: 40px; color: #CCC">
          <i class="fa fa-frown-o"></i>
        </div>
      </span>
    </div>

    <div>
      <div class="widget-spinner" data-bind="visible: $root.isRetrievingResults()">
        <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
        <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
      </div>

      <div data-bind="visible: !$root.isRetrievingResults() && $root.results().length == 0">
        </br>
        ${ _('Your search did not match any documents.') }
      </div>

      <div data-bind="visible: !$root.isRetrievingResults() && $root.results().length > 0">
        <!-- ko if: $root.response().response -->
          <div data-bind="template: {name: 'resultset-pagination', data: $root.response() }" style="padding: 8px; color: #666"></div>
        <!-- /ko -->

        <div id="result-main" style="overflow-x: auto">
          <table id="result-container" data-bind="visible: ! $root.isRetrievingResults()" style="margin-top: 0; width: 100%">
            <thead>
              <tr data-bind="visible: $root.collection.template.fieldsSelected().length > 0">
                <th style="width: 18px">&nbsp;</th>
                <!-- ko foreach: $root.collection.template.fieldsSelected -->
                <th data-bind="with: $root.collection.getTemplateField($data), event: { mouseover: $root.enableGridlayoutResultChevron, mouseout: $root.disableGridlayoutResultChevron }" style="white-space: nowrap">
                  <div style="display: inline-block; width:20px;">
                    <a href="javascript: void(0)" data-bind="click: function(){ $root.collection.translateSelectedField($index(), 'left'); }">
                      <i class="fa fa-chevron-left" data-bind="visible: $root.toggledGridlayoutResultChevron() && $index() > 0"></i>
                      <i class="fa fa-chevron-left" style="color: #FFF" data-bind="visible: !$root.toggledGridlayoutResultChevron() || $index() == 0"></i>
                    </a>
                  </div>
                  <div style="display: inline-block;">
                    <a href="javascript: void(0)" data-bind="click: $root.collection.toggleSortColumnGridLayout" title="${ _('Click to sort') }">
                      <span data-bind="text: name"></span>
                      <i class="fa" data-bind="visible: sort.direction() != null, css: { 'fa-chevron-down': sort.direction() == 'desc', 'fa-chevron-up': sort.direction() == 'asc' }"></i>
                    </a>
                  </div>
                  <div style="display: inline-block; width:20px;">
                    <a href="javascript: void(0)" data-bind="click: function(){ $root.collection.translateSelectedField($index(), 'right'); }">
                      <i class="fa fa-chevron-right" data-bind="visible: $root.toggledGridlayoutResultChevron() && $index() < $root.collection.template.fields().length - 1"></i>
                      <i class="fa fa-chevron-up" style="color: #FFF" data-bind="visible: !$root.toggledGridlayoutResultChevron() || $index() == $root.collection.template.fields().length - 1,"></i>
                    </a>
                  </div>
                </th>
                <!-- /ko -->
              </tr>
              <tr data-bind="visible: $root.collection.template.fieldsSelected().length == 0">
                <th style="width: 18px">&nbsp;</th>
                <th>${ ('Document') }</th>
              </tr>
            </thead>
            <tbody data-bind="foreach: { data: $root.results, as: 'documents'}" class="result-tbody">
              <tr class="result-row">
                <td>
                  <a href="javascript:void(0)" data-bind="click: toggleDocDetails">
                    <i class="fa" data-bind="css: {'fa-caret-right' : ! showDetails(), 'fa-caret-down' : showDetails() }"></i>
                  </a>
                </td>
                <!-- ko foreach: row -->
                  <td data-bind="html: $data"></td>
                <!-- /ko -->
              </tr>
              <tr data-bind="visible: showDetails">
                <td data-bind="attr: {'colspan': $root.collection.template.fieldsSelected().length > 0 ? $root.collection.template.fieldsSelected().length + 1 : 2}">
                  <!-- ko if: $data.details().length == 0 -->
                    <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
                    <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
                  <!-- /ko -->
                  <!-- ko if: $data.details().length > 0 -->
                    <div class="document-details">
                      <table>
                        <tbody data-bind="foreach: details">
                          <tr>
                             <th style="text-align: left; white-space: nobreak; vertical-align:top; padding-right:20px", data-bind="text: key"></th>
                             <td width="100%" data-bind="text: value"></td>
                          </tr>
                        </tbody>
                      </table>
                    </div>
                  <!-- /ko -->
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  <!-- /ko -->
</script>

<script type="text/html" id="html-resultset-widget">
  <!-- ko ifnot: $root.collection.template.isGridLayout() -->
    <div data-bind="visible: $root.isEditing" style="margin-bottom: 20px">
      <ul class="nav nav-pills">
        <li class="active"><a href="javascript: void(0)" class="widget-editor-pill">${_('Editor')}</a></li>
        <li><a href="javascript: void(0)" class="widget-html-pill">${_('HTML')}</a></li>
        <li><a href="javascript: void(0)" class="widget-css-pill">${_('CSS & JS')}</a></li>
        <li><a href="javascript: void(0)" class="widget-settings-pill">${_('Properties')}</a></li>
      </ul>
    </div>

    <!-- ko if: $root.isEditing() -->
      <div class="widget-section widget-editor-section">
        <div class="row-fluid">
          <div class="span9">
            <div data-bind="freshereditor: {data: $root.collection.template.template}"></div>
          </div>
          <div class="span3">
            <h5 class="editor-title">${_('Available Fields')}</h5>
            <select data-bind="options: $root.collection.fields, optionsText: 'name', value: $root.collection.template.selectedVisualField" class="input-large chosen-select"></select>
            <button title="${ _('Click on this button to add the field') }" class="btn plus-btn" data-bind="click: $root.collection.template.addFieldToVisual">
              <i class="fa fa-plus"></i>
            </button>

            <h5 class="editor-title" style="margin-top: 30px">${_('Available Functions')}</h2>
            <select id="visualFunctions" data-bind="value: $root.collection.template.selectedVisualFunction" class="input-large chosen-select">
              <option title="${ _('Formats date or timestamp in DD-MM-YYYY') }" value="{{#date}} {{/date}}">{{#date}}</option>
              <option title="${ _('Formats date or timestamp in HH:mm:ss') }" value="{{#time}} {{/time}}">{{#time}}</option>
              <option title="${ _('Formats date or timestamp in DD-MM-YYYY HH:mm:ss') }" value="{{#datetime}} {{/datetime}}">{{#datetime}}</option>
              <option title="${ _('Formats a date in the full format') }" value="{{#fulldate}} {{/fulldate}}">{{#fulldate}}</option>
              <option title="${ _('Formats a date as a Unix timestamp') }" value="{{#timestamp}} {{/timestamp}}">{{#timestamp}}</option>
              <option title="${ _('Formats a Unix timestamp as Ns, Nmin, Ndays... ago') }" value="{{#fromnow}} {{/fromnow}}">{{#fromnow}}</option>
              <option title="${ _('Downloads and embed the file in the browser') }" value="{{#embeddeddownload}} {{/embeddeddownload}}">{{#embeddeddownload}}</option>
              <option title="${ _('Downloads the linked file') }" value="{{#download}} {{/download}}">{{#download}}</option>
              <option title="${ _('Preview file in File Browser') }" value="{{#preview}} {{/preview}}">{{#preview}}</option>
              <option title="${ _('Truncate a value after 100 characters') }" value="{{#truncate100}} {{/truncate100}}">{{#truncate100}}</option>
              <option title="${ _('Truncate a value after 250 characters') }" value="{{#truncate250}} {{/truncate250}}">{{#truncate250}}</option>
              <option title="${ _('Truncate a value after 500 characters') }" value="{{#truncate500}} {{/truncate500}}">{{#truncate500}}</option>
            </select>
            <button title="${ _('Click on this button to add the function') }" class="btn plus-btn" data-bind="click: $root.collection.template.addFunctionToVisual">
              <i class="fa fa-plus"></i>
            </button>
            <p class="muted" style="margin-top: 10px"></p>
          </div>
        </div>
      </div>
      <div class="widget-section widget-html-section" style="display: none">
        <div class="row-fluid">
          <div class="span9">
            <textarea data-bind="codemirror: {data: $root.collection.template.template, lineNumbers: true, htmlMode: true, mode: 'text/html' }" data-template="true"></textarea>
          </div>
          <div class="span3">
            <h5 class="editor-title">${_('Available Fields')}</h2>
            <select data-bind="options: $root.collection.fields, optionsText: 'name', value: $root.collection.template.selectedSourceField" class="input-medium chosen-select"></select>
            <button title="${ _('Click on this button to add the field') }" class="btn plus-btn" data-bind="click: $root.collection.template.addFieldToSource">
              <i class="fa fa-plus"></i>
            </button>

            <h5 class="editor-title" style="margin-top: 30px">${_('Available Functions')}</h2>
            <select id="sourceFunctions" data-bind="value: $root.collection.template.selectedSourceFunction" class="input-medium chosen-select">
              <option title="${ _('Formats a date in the DD-MM-YYYY format') }" value="{{#date}} {{/date}}">{{#date}}</option>
              <option title="${ _('Formats a date in the HH:mm:ss format') }" value="{{#time}} {{/time}}">{{#time}}</option>
              <option title="${ _('Formats a date in the DD-MM-YYYY HH:mm:ss format') }" value="{{#datetime}} {{/datetime}}">{{#datetime}}</option>
              <option title="${ _('Formats a date in the full format') }" value="{{#fulldate}} {{/fulldate}}">{{#fulldate}}</option>
              <option title="${ _('Formats a date as a Unix timestamp') }" value="{{#timestamp}} {{/timestamp}}">{{#timestamp}}</option>
              <option title="${ _('Shows the relative time') }" value="{{#fromnow}} {{/fromnow}}">{{#fromnow}}</option>
              <option title="${ _('Downloads and embed the file in the browser') }" value="{{#embeddeddownload}} {{/embeddeddownload}}">{{#embeddeddownload}}</option>
              <option title="${ _('Downloads the linked file') }" value="{{#download}} {{/download}}">{{#download}}</option>
              <option title="${ _('Preview file in File Browser') }" value="{{#preview}} {{/preview}}">{{#preview}}</option>
              <option title="${ _('Truncate a value after 100 characters') }" value="{{#truncate100}} {{/truncate100}}">{{#truncate100}}</option>
              <option title="${ _('Truncate a value after 250 characters') }" value="{{#truncate250}} {{/truncate250}}">{{#truncate250}}</option>
              <option title="${ _('Truncate a value after 500 characters') }" value="{{#truncate500}} {{/truncate500}}">{{#truncate500}}</option>
            </select>
            <button title="${ _('Click on this button to add the function') }" class="btn plus-btn" data-bind="click: $root.collection.template.addFunctionToSource">
              <i class="fa fa-plus"></i>
            </button>
            <p class="muted" style="margin-top: 10px"></p>
          </div>
        </div>
      </div>
      <div class="widget-section widget-css-section" style="display: none">
        <textarea data-bind="codemirror: {data: $root.collection.template.extracode, lineNumbers: true, htmlMode: true, mode: 'text/html' }"></textarea>
      </div>
      <div class="widget-section widget-settings-section" style="display: none, min-height:200px">
        ${ _('Sorting') }

        <div data-bind="foreach: $root.collection.template.fieldsSelected">
          <span data-bind="text: $data"></span>
        </div>
        <br/>
      </div>
    <!-- /ko -->

    <div id="result-main" style="overflow-x: auto">
      <div data-bind="visible: !$root.isRetrievingResults() && $root.results().length == 0">
        </br>
        ${ _('Your search did not match any documents.') }
      </div>

      <!-- ko if: $root.response().response && $root.results().length > 0 -->
        <div data-bind="template: {name: 'resultset-pagination', data: $root.response() }"></div>
      <!-- /ko -->

      <div id="result-container" data-bind="foreach: $root.results">
        <div class="result-row" data-bind="html: $data"></div>
      </div>

      <div class="widget-spinner" data-bind="visible: $root.isRetrievingResults()">
        <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
        <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
      </div>
    </div>
  <!-- /ko -->
</script>

<script type="text/html" id="resultset-pagination">
<div style="text-align: center; margin-top: 4px">
  <a href="javascript: void(0)" title="${ _('Previous') }">
    <span data-bind="text: name, click: $root.collection.toggleSortColumnGridLayout"></span>
    <i class="fa fa-arrow-left" data-bind="
        visible: $data.response.start * 1.0 >= $root.collection.template.rows() * 1.0,
        click: function() { $root.query.paginate('prev') }">
    </i>
  </a>

  ${ _('Showing') }
  <span data-bind="text: ($data.response.start + 1)"></span>
  ${ _('to') }
  <span data-bind="text: ($data.response.start + $root.collection.template.rows())"></span>
  ${ _('of') }
  <span data-bind="text: $data.response.numFound"></span>
  ${ _(' results') }

  <span data-bind="visible: $root.isEditing()">
    ${ _('Show') }
    <span class="spinedit-cnt">
      <input type="text" data-bind="spinedit: $root.collection.template.rows, valueUpdate:'afterkeydown'" style="text-align: center; margin-bottom: 0" />
    </span>
    ${ _('results per page') }
  </span>

  <a href="javascript: void(0)" title="${ _('Next') }">
    <span data-bind="text: name, click: $root.collection.toggleSortColumnGridLayout"></span>
    <i class="fa fa-arrow-right" data-bind="
        visible: ($root.collection.template.rows() * 1.0 + $data.response.start * 1.0) < $data.response.numFound,
        click: function() { $root.query.paginate('next') }">
    </i>
  </a>

  <!-- ko if: $data.response.numFound > 0 && $data.response.numFound <= 1000 -->
  <span class="pull-right">
    <form method="POST" action="${ url('search:download') }">
      <input type="hidden" name="collection" data-bind="value: ko.mapping.toJSON($root.collection)"/>
      <input type="hidden" name="query" data-bind="value: ko.mapping.toJSON($root.query)"/>
      <button class="btn" type="submit" name="json" title="${ _('Download as JSON') }"><i class="hfo hfo-file-json"></i></button>
      <button class="btn" type="submit" name="csv" title="${ _('Download as CSV') }"><i class="hfo hfo-file-csv"></i></button>
      <button class="btn" type="submit" name="xls" title="${ _('Download as Excel') }"><i class="hfo hfo-file-xls"></i></button>
    </form>
  </span>
  <!-- /ko -->
</div>
</script>

<script type="text/html" id="histogram-widget">
  <div class="widget-spinner" data-bind="visible: isLoading()">
    <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
    <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
  </div>

  <!-- ko if: $root.getFacetFromQuery(id()) -->
  <div class="row-fluid" data-bind="with: $root.getFacetFromQuery(id())">
    <div data-bind="visible: $root.isEditing, with: $root.collection.getFacetById($parent.id())" style="margin-bottom: 20px">
      <span data-bind="template: { name: 'facet-toggle' }">
      </span>
    </div>

    <div style="padding-bottom: 10px; text-align: right; padding-right: 20px">
      <span class="facet-field-label">${ _('Zoom') }</span>
      <a href="javascript:void(0)" data-bind="click: $root.collection.timeLineZoom"><i class="fa fa-search-minus"></i> ${ _('reset') }</a> &nbsp;|&nbsp;
      <span class="facet-field-label">${ _('Group by') }</span>
      <select class="input-medium" data-bind="options: $root.query.multiqs, optionsValue: 'id',optionsText: 'label', value: $root.query.selectedMultiq"></select>
    </div>

    <div data-bind="timelineChart: {datum: {counts: counts, extraSeries: extraSeries, widget_id: $parent.id(), label: label}, stacked: $root.collection.getFacetById($parent.id()).properties.stacked(), field: field, label: label, transformer: timelineChartDataTransformer,
      fqs: $root.query.fqs,
      onSelectRange: function(from, to){ viewModel.collection.selectTimelineFacet({from: from, to: to, cat: field, widget_id: $parent.id()}) },
      onStateChange: function(state){ $root.collection.getFacetById($parent.id()).properties.stacked(state.stacked); },
      onClick: function(d){ viewModel.query.selectRangeFacet({count: d.obj.value, widget_id: $parent.id(), from: d.obj.from, to: d.obj.to, cat: d.obj.field}) },
      onComplete: function(){ viewModel.getWidgetById(id).isLoading(false) }}" />
  </div>
  <!-- /ko -->
</script>

<script type="text/html" id="bar-widget">
  <div class="widget-spinner" data-bind="visible: isLoading()">
    <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
    <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
  </div>

  <!-- ko if: $root.getFacetFromQuery(id()) -->
  <div class="row-fluid" data-bind="with: $root.getFacetFromQuery(id())">
    <div data-bind="visible: $root.isEditing, with: $root.collection.getFacetById($parent.id())" style="margin-bottom: 20px">
      <span data-bind="template: { name: 'facet-toggle' }">
      </span>
    </div>

    <div data-bind="with: $root.collection.getFacetById($parent.id())">
      <!-- ko if: type() == 'range' -->
        <a href="javascript:void(0)" data-bind="click: $root.collection.timeLineZoom"><i class="fa fa-search-minus"></i></a>
      <!-- /ko -->
    </div>

    <div data-bind="barChart: {datum: {counts: counts, widget_id: $parent.id(), label: label}, stacked: false, field: field, label: label,
      fqs: $root.query.fqs,
      transformer: barChartDataTransformer,
      onStateChange: function(state){ console.log(state); },
      onClick: function(d) {
        if (d.obj.field != undefined) {
          viewModel.query.selectRangeFacet({count: d.obj.value, widget_id: d.obj.widget_id, from: d.obj.from, to: d.obj.to, cat: d.obj.field});
        } else {
          viewModel.query.toggleFacet({facet: d.obj, widget_id: d.obj.widget_id});
        }
      },
      onSelectRange: function(from, to){ viewModel.collection.selectTimelineFacet({from: from, to: to, cat: field, widget_id: id}) },
      onComplete: function(){ viewModel.getWidgetById(id).isLoading(false) } }"
    />
  </div>
  <!-- /ko -->
</script>

<script type="text/html" id="line-widget">
  <div class="widget-spinner" data-bind="visible: isLoading()">
    <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
    <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
  </div>

  <!-- ko if: $root.getFacetFromQuery(id()) -->
  <div class="row-fluid" data-bind="with: $root.getFacetFromQuery(id())">
    <div data-bind="visible: $root.isEditing, with: $root.collection.getFacetById($parent.id())" style="margin-bottom: 20px">
      <span data-bind="template: { name: 'facet-toggle' }">
      </span>
    </div>

    <a href="javascript:void(0)" data-bind="click: $root.collection.timeLineZoom"><i class="fa fa-search-minus"></i></a>

    <div data-bind="lineChart: {datum: {counts: counts, widget_id: $parent.id(), label: label}, field: field, label: label,
      transformer: lineChartDataTransformer,
      onClick: function(d){ viewModel.query.selectRangeFacet({count: d.obj.value, widget_id: d.obj.widget_id, from: d.obj.from, to: d.obj.to, cat: d.obj.field}) },
      onSelectRange: function(from, to){ viewModel.collection.selectTimelineFacet({from: from, to: to, cat: field, widget_id: $parent.id()}) },
      onComplete: function(){ viewModel.getWidgetById(id).isLoading(false) } }"
    />
  </div>
  <!-- /ko -->
</script>


<script type="text/html" id="pie-widget">
  <!-- ko if: $root.getFacetFromQuery(id()) -->
  <div class="row-fluid" data-bind="with: $root.getFacetFromQuery(id())">
    <div data-bind="visible: $root.isEditing, with: $root.collection.getFacetById($parent.id())" style="margin-bottom: 20px">
      <span data-bind="template: { name: 'facet-toggle' }">
      </span>
    </div>

    <div data-bind="with: $root.collection.getFacetById($parent.id())">
      <!-- ko if: type() == 'range' -->
      <div data-bind="pieChart: {data: {counts: $parent.counts, widget_id: $parent.id}, field: field, fqs: $root.query.fqs,
        transformer: rangePieChartDataTransformer,
        maxWidth: 250,
        onClick: function(d){ viewModel.query.selectRangeFacet({count: d.data.obj.value, widget_id: d.data.obj.widget_id, from: d.data.obj.from, to: d.data.obj.to, cat: d.data.obj.field}) },
        onComplete: function(){ viewModel.getWidgetById($parent.id).isLoading(false)} }" />
      <!-- /ko -->
      <!-- ko if: type() != 'range' -->
      <div data-bind="pieChart: {data: {counts: $parent.counts, widget_id: $parent.id}, field: field, fqs: $root.query.fqs,
        transformer: pieChartDataTransformer,
        maxWidth: 250,
        onClick: function(d){viewModel.query.toggleFacet({facet: d.data.obj, widget_id: d.data.obj.widget_id})},
        onComplete: function(){viewModel.getWidgetById($parent.id).isLoading(false)}}" />
      <!-- /ko -->
    </div>
  </div>
  <!-- /ko -->
  <div class="widget-spinner" data-bind="visible: isLoading()">
    <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
    <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
  </div>
</script>

<script type="text/html" id="filter-widget">
  <div data-bind="visible: $root.query.fqs().length == 0" style="margin-top: 10px">${_('There are currently no filters applied.')}</div>
  <div data-bind="foreach: { data: $root.query.fqs, afterRender: function(){ isLoading(false); } }">
    <!-- ko if: $data.type() == 'field' -->
    <div class="filter-box">
      <a href="javascript:void(0)" class="pull-right" data-bind="click: function(){ chartsUpdatingState(); viewModel.query.removeFilter($data); viewModel.search() }"><i class="fa fa-times"></i></a>
      <strong>${_('field')}</strong>:
      <span data-bind="text: $data.field"></span>
      <br/>
      <strong>${_('value')}</strong>:
      <span data-bind="text: $data.filter"></span>
    </div>
    <!-- /ko -->
    <!-- ko if: $data.type() == 'range' -->
    <div class="filter-box">
      <a href="javascript:void(0)" class="pull-right" data-bind="click: function(){ chartsUpdatingState(); viewModel.query.removeFilter($data); viewModel.search() }"><i class="fa fa-times"></i></a>
      <strong>${_('field')}</strong>:
      <span data-bind="text: $data.field"></span>
      <br/>
      <span data-bind="foreach: $data.properties" style="font-weight: normal">
        <strong>${_('from')}</strong>: <span data-bind="text: $data.from"></span>
        <br/>
        <strong>${_('to')}</strong>: <span data-bind="text: $data.to"></span>
      </span>
    </div>
    <!-- /ko -->
  </div>
  <div class="clearfix"></div>
  <div class="widget-spinner" data-bind="visible: isLoading() &&  $root.query.fqs().length > 0">
    <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
    <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
  </div>
</script>

<script type="text/html" id="map-widget">
  <!-- ko if: $root.getFacetFromQuery(id()) -->
  <div class="row-fluid" data-bind="with: $root.getFacetFromQuery(id())">
    <div data-bind="visible: $root.isEditing, with: $root.collection.getFacetById($parent.id())" style="margin-bottom: 20px">
      ${ _('Scope') }:
      <select data-bind="selectedOptions: properties.scope" class="input-small">
        <option value="world">${ _("World") }</option>
        <option value="usa">${ _("USA") }</option>
      </select>
      <span data-bind="template: { name: 'facet-toggle' }">
      </span>
    </div>
    <div data-bind="with: $root.collection.getFacetById($parent.id())">
      <div data-bind="mapChart: {data: {counts: $parent.counts, scope: $root.collection.getFacetById($parent.id).properties.scope()},
        transformer: mapChartDataTransformer,
        maxWidth: 750,
        isScale: true,
        onClick: function(d){ viewModel.query.toggleFacet({facet: d, widget_id: $parent.id}) },
        onComplete: function(){ var widget = viewModel.getWidgetById($parent.id); if (widget != null) {widget.isLoading(false)};} }" />
    </div>
  </div>
  <!-- /ko -->
  <div class="widget-spinner" data-bind="visible: isLoading()">
    <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
    <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
  </div>
</script>

<div id="shareModal" class="modal hide" data-backdrop="true">
  <div class="modal-header">
    <a href="javascript: void(0)" data-dismiss="modal" class="pull-right"><i class="fa fa-times"></i></a>
    <h3>${_('Share this dashboard')}</h3>
  </div>
  <div class="modal-body">
    <p>${_('The following URL will show the current dashboard and the applied filters.')}</p>
    <input type="text" style="width: 540px" />
  </div>
  <div class="modal-footer">
    <a href="#" class="btn" data-dismiss="modal">${_('Close')}</a>
  </div>
</div>


<div id="addFacetDemiModal" class="demi-modal hide" data-backdrop="false">
  <div class="modal-body">
    <a href="javascript: void(0)" data-dismiss="modal" data-bind="click: addFacetDemiModalFieldCancel" class="pull-right"><i class="fa fa-times"></i></a>
    <div style="float: left; margin-right: 10px;text-align: center">
      <input id="addFacetInput" type="text" data-bind="clearable: $root.collection.template.fieldsModalFilter, valueUpdate:'afterkeydown'" placeholder="${_('Filter fields')}" class="input" style="float: left" /><br/>
    </div>
    <div>
      <ul data-bind="foreach: $root.collection.template.filteredModalFields().sort(function (l, r) { return l.name() > r.name() ? 1 : -1 }), visible: $root.collection.template.filteredModalFields().length > 0"
          class="unstyled inline fields-chooser" style="height: 100px; overflow-y: auto">
        <li data-bind="click: addFacetDemiModalFieldPreview">
          <span class="badge badge-info"><span data-bind="text: name(), attr: {'title': type()}"></span>
          </span>
        </li>
      </ul>
      <div class="alert alert-info inline" data-bind="visible: $root.collection.template.filteredModalFields().length == 0" style="margin-left: 250px;margin-right: 50px; height: 42px;line-height: 42px">
        ${_('There are no fields matching your search term.')}
      </div>
    </div>
  </div>
</div>

<div id="settingsDemiModal" class="demi-modal hide" data-backdrop="false">
  <div class="modal-body">
    <a href="javascript: void(0)" data-dismiss="modal" class="pull-right"><i class="fa fa-times"></i></a>
    <div style="float: left; margin-right: 30px; text-align: center; line-height: 28px">
      <!-- ko if: $root.initial.inited() -->
      ${ _('Solr index') }
      <select data-bind="options: $root.initial.collections, value: $root.collection.name" style="margin-bottom: 0">
      </select>
      <!-- /ko -->
    </div>
    <label class="checkbox" style="margin-top: 4px">
      ${ _('Visible to everybody') } <input type="checkbox" data-bind="checked: $root.collection.enabled"/>
    </label>
  </div>
</div>


## Extra code for style and custom JS
<span id="extra" data-bind="augmenthtml: $root.collection.template.extracode"></span>


<link rel="stylesheet" href="/search/static/css/search.css">
<link rel="stylesheet" href="/static/ext/css/hue-filetypes.css">
<link rel="stylesheet" href="/static/ext/css/leaflet.css">
<link rel="stylesheet" href="/static/ext/css/hue-charts.css">
<link rel="stylesheet" href="/static/css/freshereditor.css">
<link rel="stylesheet" href="/static/ext/css/codemirror.css">
<link rel="stylesheet" href="/static/ext/css/bootstrap-editable.css">
<link rel="stylesheet" href="/static/ext/css/bootstrap-datepicker.min.css">
<link rel="stylesheet" href="/static/ext/css/bootstrap-timepicker.min.css">
<link rel="stylesheet" href="/static/css/bootstrap-spinedit.css">
<link rel="stylesheet" href="/static/css/bootstrap-slider.css">
<link rel="stylesheet" href="/static/ext/css/nv.d3.min.css">
<link rel="stylesheet" href="/search/static/css/nv.d3.css">
<link rel="stylesheet" href="/static/ext/chosen/chosen.min.css">

<script src="/static/ext/js/moment-with-langs.min.js" type="text/javascript" charset="utf-8"></script>

<script src="/search/static/js/search.utils.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/lzstring.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/knockout-min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/knockout.mapping-2.3.2.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/knockout-sortable.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/bootstrap-editable.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/bootstrap-datepicker.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/bootstrap-timepicker.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/bootstrap-spinedit.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/bootstrap-slider.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/ko.editable.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/shortcut.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/freshereditor.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/codemirror-3.11.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/codemirror-xml.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/mustache.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/jquery/plugins/jquery-ui-1.10.4.draggable-droppable-sortable.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/jquery/plugins/jquery.flot.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/jquery/plugins/jquery.flot.categories.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/leaflet/leaflet.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/chosen/chosen.jquery.min.js" type="text/javascript" charset="utf-8"></script>

<script src="/search/static/js/search.ko.js" type="text/javascript" charset="utf-8"></script>

<script src="/static/js/hue.geo.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/hue.colors.js" type="text/javascript" charset="utf-8"></script>

<script src="/static/ext/js/d3.v3.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/nv.d3.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/topojson.v1.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/topo/world.topo.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/topo/usa.topo.js" type="text/javascript" charset="utf-8"></script>

<script src="/search/static/js/nv.d3.datamaps.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/nv.d3.legend.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/nv.d3.multiBarWithBrushChart.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/nv.d3.lineWithBrushChart.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/nv.d3.growingDiscreteBar.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/nv.d3.growingDiscreteBarChart.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/nv.d3.growingMultiBar.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/nv.d3.growingMultiBarChart.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/nv.d3.growingPie.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/nv.d3.growingPieChart.js" type="text/javascript" charset="utf-8"></script>
<script src="/search/static/js/charts.ko.js" type="text/javascript" charset="utf-8"></script>

<script src="/static/ext/js/less-1.7.0.min.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript" charset="utf-8">
var viewModel;

nv.dev = false;

var lastWindowScrollPosition = 0;

function pieChartDataTransformer(data) {
  var _data = [];
  $(data.counts).each(function (cnt, item) {
    item.widget_id = data.widget_id;
    _data.push({
      label: item.value,
      value: item.count,
      obj: item
    });
  });
  return _data;
}

function rangePieChartDataTransformer(data) {
  var _data = [];
  $(data.counts).each(function (cnt, item) {
    item.widget_id = data.widget_id;
    _data.push({
      label: item.from + ' - ' + item.to,
      from: item.from,
      to: item.to,
      value: item.value,
      obj: item
    });
  });
  return _data;
}

function barChartDataTransformer(rawDatum) {
  var _datum = [];
  var _data = [];

  $(rawDatum.counts).each(function (cnt, item) {
    item.widget_id = rawDatum.widget_id;
    if (typeof item.from != "undefined") {
      _data.push({
        series: 0,
        x: item.from,
        x_end: item.to,
        y: item.value,
        obj: item
      });
    }
    else {
      _data.push({
        series: 0,
        x: item.value,
        y: item.count,
        obj: item
      });
    }
  });
  _datum.push({
    key: rawDatum.label,
    values: _data
  });
  return _datum;
}

function lineChartDataTransformer(rawDatum) {
  var _datum = [];
  var _data = [];
  $(rawDatum.counts).each(function (cnt, item) {
    item.widget_id = rawDatum.widget_id;
    if (typeof item.from != "undefined") {
      _data.push({
        series: 0,
        x: item.from,
        x_end: item.to,
        y: item.value,
        obj: item
      });
    }
    else {
      _data.push({
        series: 0,
        x: item.value,
        y: item.count,
        obj: item
      });
    }
  });
  _datum.push({
    key: rawDatum.label,
    values: _data
  });
  return _datum;
}

function timelineChartDataTransformer(rawDatum) {
  var _datum = [];
  var _data = [];

  $(rawDatum.counts).each(function (cnt, item) {
    _data.push({
      series: 0,
      x: new Date(moment(item.from).valueOf()),
      y: item.value,
      obj: item
    });
  });

  _datum.push({
    key: rawDatum.label,
    values: _data
  });


  // If multi query
  $(rawDatum.extraSeries).each(function (cnt, item) {
    if (cnt == 0) {
      _datum = [];
    }
    var _data = [];
    $(item.counts).each(function (cnt, item) {
      _data.push({
        series: cnt + 1,
        x: new Date(moment(item.from).valueOf()),
        y: item.value,
        obj: item
      });
    });

    _datum.push({
      key: item.label,
      values: _data
    });
  });

  return _datum;
}

function mapChartDataTransformer(data) {
  var _data = [];
  $(data.counts).each(function (cnt, item) {
    _data.push({
      label: item.value,
      value: item.count,
      obj: item
    });
  });
  return _data;
}

function toggleDocDetails(doc) {
  doc.showDetails(! doc.showDetails());

  if (doc.details().length == 0) {
    viewModel.getDocument(doc);
  }
}

function resizeFieldsList() {
  $(".fields-list").css("max-height", Math.max($("#result-container").height(), 230));
}

$(document).ready(function () {

  var _resizeTimeout = -1;
  $(window).resize(function(){
    window.clearTimeout(_resizeTimeout);
    window.setTimeout(function(){
      resizeFieldsList();
    }, 200);
  });

  $(document).on("click", ".widget-settings-pill", function(){
    $(this).parents(".card-body").find(".widget-section").hide();
    $(this).parents(".card-body").find(".widget-settings-section").show();
    $(this).parent().siblings().removeClass("active");
    $(this).parent().addClass("active");
  });

  $(document).on("click", ".widget-editor-pill", function(){
    $(this).parents(".card-body").find(".widget-section").hide();
    $(this).parents(".card-body").find(".widget-editor-section").show();
    $(this).parent().siblings().removeClass("active");
    $(this).parent().addClass("active");
  });

  $(document).on("click", ".widget-html-pill", function(){
    $(this).parents(".card-body").find(".widget-section").hide();
    $(this).parents(".card-body").find(".widget-html-section").show();
    $(document).trigger("refreshCodemirror");
    $(this).parent().siblings().removeClass("active");
    $(this).parent().addClass("active");
  });

  $(document).on("click", ".widget-css-pill", function(){
    $(this).parents(".card-body").find(".widget-section").hide();
    $(this).parents(".card-body").find(".widget-css-section").show();
    $(document).trigger("refreshCodemirror");
    $(this).parent().siblings().removeClass("active");
    $(this).parent().addClass("active");
  });

  $(document).on("magicLayout", function(){
    resizeFieldsList();
  });

  ko.bindingHandlers.slideVisible = {
    init: function (element, valueAccessor) {
      var value = valueAccessor();
      $(element).toggle(ko.unwrap(value));
    },
    update: function (element, valueAccessor) {
      var value = valueAccessor();
      ko.unwrap(value) ? $(element).slideDown(100) : $(element).slideUp(100);
    }
  };

  ko.bindingHandlers.fadeVisible = {
    init: function(element, valueAccessor) {
      var value = valueAccessor();
      $(element).toggle(ko.unwrap(value));
    },
    update: function(element, valueAccessor) {
      var value = valueAccessor();
      $(element).stop();
      ko.unwrap(value) ? $(element).fadeIn() : $(element).hide();
    }
};


  ko.extenders.numeric = function (target, precision) {
    var result = ko.computed({
      read: target,
      write: function (newValue) {
        var current = target(),
          roundingMultiplier = Math.pow(10, precision),
          newValueAsNum = isNaN(newValue) ? 0 : parseFloat(+newValue),
          valueToWrite = Math.round(newValueAsNum * roundingMultiplier) / roundingMultiplier;

        if (valueToWrite !== current) {
          target(valueToWrite);
        } else {
          if (newValue !== current) {
            target.notifySubscribers(valueToWrite);
          }
        }
      }
    }).extend({ notify: 'always' });
    result(target());
    return result;
  };

  ko.bindingHandlers.freshereditor = {
    init: function (element, valueAccessor, allBindingsAccessor, viewModel) {
      var _el = $(element);
      var options = $.extend(valueAccessor(), {});
      _el.html(options.data());
      _el.freshereditor({
        excludes: ['strikethrough', 'removeFormat', 'insertorderedlist', 'justifyfull', 'insertheading1', 'insertheading2', 'superscript', 'subscript']
      });
      _el.freshereditor("edit", true);
      _el.on("mouseup", function () {
        storeSelection();
        updateValues();
      });

      var sourceDelay = -1;
      _el.on("keyup", function () {
        clearTimeout(sourceDelay);
        storeSelection();
        sourceDelay = setTimeout(function () {
          updateValues();
        }, 100);
      });

      $(".chosen-select").chosen({
        disable_search_threshold: 10,
        width: "75%"
      });

      $(document).on("addFieldToVisual", function(e, field){
        _el.focus();
        pasteHtmlAtCaret("{{" + field.name() + "}}");
      });

      $(document).on("addFunctionToVisual", function(e, fn){
        _el.focus();
        pasteHtmlAtCaret(fn);
      });

      function updateValues(){
        $("[data-template]")[0].editor.setValue(stripHtmlFromFunctions(_el.html()));
        valueAccessor().data(_el.html());
      }

      function storeSelection() {
        if (window.getSelection) {
          // IE9 and non-IE
          sel = window.getSelection();
          if (sel.getRangeAt && sel.rangeCount) {
            range = sel.getRangeAt(0);
            _el.data("range", range);
          }
        }
        else if (document.selection && document.selection.type != "Control") {
          // IE < 9
          _el.data("selection", document.selection);
        }
      }

    function pasteHtmlAtCaret(html) {
      var sel, range;
      if (window.getSelection) {
        // IE9 and non-IE
        sel = window.getSelection();
        if (sel.getRangeAt && sel.rangeCount) {
          if (_el.data("range")) {
            range = _el.data("range");
          }
          else {
            range = sel.getRangeAt(0);
          }
          range.deleteContents();

          // Range.createContextualFragment() would be useful here but is
          // non-standard and not supported in all browsers (IE9, for one)
          var el = document.createElement("div");
          el.innerHTML = html;
          var frag = document.createDocumentFragment(), node, lastNode;
          while ((node = el.firstChild)) {
            lastNode = frag.appendChild(node);
          }
          range.insertNode(frag);

          // Preserve the selection
          if (lastNode) {
            range = range.cloneRange();
            range.setStartAfter(lastNode);
            range.collapse(true);
            sel.removeAllRanges();
            sel.addRange(range);
          }
        }
      } else if (document.selection && document.selection.type != "Control") {
        // IE < 9
        if (_el.data("selection")) {
          _el.data("selection").createRange().pasteHTML(html);
        }
        else {
          document.selection.createRange().pasteHTML(html);
        }
      }
    }
    }
  };

  ko.bindingHandlers.slider = {
    init: function (element, valueAccessor, allBindingsAccessor, viewModel) {
      var _el = $(element);
      var _options = $.extend(valueAccessor(), {});
      _el.slider({
        min: _options.start() ? _options.start() : 1,
        max: _options.end() ? _options.end() : 10,
        step: _options.gap() ? _options.gap() : 1,
        handle: _options.handle ? _options.handle : 'triangle',
        start: _options.min(),
        end: _options.max(),
        tooltip_split: true,
        tooltip: 'always'
      });
      _el.on("slide", function (e) {
        _options.start(e.min);
        _options.end(e.max);
        _options.min(e.start);
        _options.max(e.end);
        _options.gap(e.step);
      });
    },
    update: function (element, valueAccessor, allBindingsAccessor) {
      var _options = $.extend(valueAccessor(), {});
    }
  }

  ko.bindingHandlers.daterangepicker = {
    init: function (element, valueAccessor, allBindingsAccessor, viewModel) {
      var DATE_FORMAT = "YYYY-MM-DD";
      var TIME_FORMAT = "HH:mm:ss";
      var DATETIME_FORMAT = DATE_FORMAT + " " + TIME_FORMAT;

      var _el = $(element);
      var _options = $.extend(valueAccessor(), {});

      var _intervalOptions = [
        '<option value="+200MILLISECONDS">200ms</option>',
        '<option value="+1SECONDS">1s</option>',
        '<option value="+1MINUTES">1m</option>',
        '<option value="+5MINUTES">5m</option>',
        '<option value="+10MINUTES">10m</option>',
        '<option value="+30MINUTES">30m</option>',
        '<option value="+1HOURS">1h</option>',
        '<option value="+3HOURS">3h</option>',
        '<option value="+12HOURS">12h</option>',
        '<option value="+1DAYS">1d</option>',
        '<option value="+7DAYS">7d</option>',
        '<option value="+1MONTHS">1M</option>',
        '<option value="+6MONTHS">6M</option>',
        '<option value="+1YEARS">1y</option>'
      ];

      function enableOptions() {
        var _opts = [];
        var _tmp = $("<div>").html(_intervalOptions.join(""))
        $.each(arguments, function(cnt, item){
          if (_tmp.find("option[value='+"+item+"']").length > 0){
            _opts.push('<option value="+'+item+'">' + _tmp.find("option[value='+"+item+"']").eq(0).text() + '</option>');
          }
        });
        return _opts;
      }

      function renderOptions(opts) {
        var _html = "";
        for (var i=0; i<opts.length; i++){
          _html += opts[i];
        }
        _html += '<option value="">${ _('Custom') }</option>';
        return _html;
      }

      var _tmpl = $('<div class="simpledaterangepicker">' +
                    '<div class="facet-field-cnt picker">' +
                      '<div class="facet-field-label facet-field-label-fixed-width">${ _('Start') }</div>' +
                      '<div class="input-prepend input-group">' +
                        '<span class="add-on input-group-addon"><i class="fa fa-calendar"></i></span>' +
                        '<input type="text" class="input-small form-control start-date" />' +
                      '</div>&nbsp;' +
                      '<div class="input-prepend input-group">' +
                        '<span class="add-on input-group-addon"><i class="fa fa-clock-o"></i></span>' +
                        '<input type="text" class="input-mini form-control start-time" />' +
                      '</div>' +
                    '</div>' +
                    '<div class="facet-field-cnt picker">' +
                      '<div class="facet-field-label facet-field-label-fixed-width">${ _('End') }</div>' +
                      '<div class="input-prepend input-group">' +
                        '<span class="add-on input-group-addon"><i class="fa fa-calendar"></i></span>' +
                        '<input type="text" class="input-small form-control end-date" />' +
                      '</div>&nbsp;' +
                      '<div class="input-prepend input-group">' +
                        '<span class="add-on input-group-addon"><i class="fa fa-clock-o"></i></span>' +
                        '<input type="text" class="input-mini form-control end-time" />' +
                      '</div>' +
                    '</div>' +
                    '<div class="facet-field-cnt picker">' +
                      '<div class="facet-field-label facet-field-label-fixed-width">${ _('Interval') }</div>' +
                      '<select class="input-small interval-select" style="margin-right: 6px">' +
                          renderOptions(_intervalOptions) +
                      '</select>' +
                      '<input class="input interval hide" type="text" value="" />' +
                    '</div>' +
                    '<div class="facet-field-cnt picker">' +
                      '<div class="facet-field-label facet-field-label-fixed-width"></div>' +
                      '<div class="facet-field-switch"><a href="javascript:void(0)"><i class="fa fa-calendar-o"></i> ${ _('Custom properties') }</a></div>' +
                    '</div>' +
                    '<div class="facet-field-cnt custom">' +
                      '<div class="facet-field-label facet-field-label-fixed-width">${ _('Start') }</div>' +
                      '<div class="input-prepend input-group">' +
                        '<span class="add-on input-group-addon"><i class="fa fa-calendar"></i></span>' +
                        '<input type="text" class="input-large form-control start-date-custom" />' +
                      '</div>' +
                    '</div>' +
                    '<div class="facet-field-cnt custom">' +
                      '<div class="facet-field-label facet-field-label-fixed-width">${ _('End') }</div>' +
                      '<div class="input-prepend input-group">' +
                        '<span class="add-on input-group-addon"><i class="fa fa-calendar"></i></span>' +
                        '<input type="text" class="input-large form-control end-date-custom" />' +
                      '</div>' +
                    '</div>' +
                    '<div class="facet-field-cnt custom">' +
                      '<div class="facet-field-label facet-field-label-fixed-width">${ _('Interval') }</div>' +
                      '<div class="input-prepend input-group">' +
                        '<span class="add-on input-group-addon"><i class="fa fa-repeat"></i></span>' +
                        '<input type="text" class="input-large form-control interval-custom" />' +
                      '</div>' +
                    '</div>' +
                    '<div class="facet-field-cnt custom">' +
                      '<div class="facet-field-label facet-field-label-fixed-width"></div>' +
                      '<div class="facet-field-switch"><a href="javascript:void(0)"><i class="fa fa-calendar"></i> ${ _('Show pickers') }</a></div>' +
                    '</div>' +

                  '</div>'
      );

      _tmpl.insertAfter(_el);

      var _minMoment = moment(_options.min());
      var _maxMoment = moment(_options.max());
      var _startMoment = moment(_options.start());
      var _endMoment = moment(_options.end());

      if (_minMoment.isValid()) {
        _tmpl.find(".facet-field-cnt.custom").hide();
        _tmpl.find(".facet-field-cnt.picker").show();
        _tmpl.find(".start-date").val(_minMoment.format(DATE_FORMAT));
        _tmpl.find(".start-time").val(_minMoment.format(TIME_FORMAT));
        _tmpl.find(".end-date").val(_maxMoment.format(DATE_FORMAT));
        _tmpl.find(".end-time").val(_maxMoment.format(TIME_FORMAT));
        _tmpl.find(".interval").val(_options.gap());
        _tmpl.find(".interval-custom").val(_options.gap());
      }
      else {
        _tmpl.find(".facet-field-cnt.custom").show();
        _tmpl.find(".facet-field-cnt.picker").hide();
        _tmpl.find(".start-date-custom").val(_options.min())
        _tmpl.find(".end-date-custom").val(_options.max())
        _tmpl.find(".interval-custom").val(_options.gap())
      }

      _tmpl.find(".start-date").datepicker({
        format: DATE_FORMAT.toLowerCase()
      }).on("changeDate", function () {
        rangeHandler(true);
      });

      _tmpl.find(".start-time").timepicker({
        minuteStep: 1,
        showSeconds: true,
        showMeridian: false,
        defaultTime: false
      });

      _tmpl.find(".end-date").datepicker({
        format: DATE_FORMAT.toLowerCase()
      }).on("changeDate", function () {
        rangeHandler(false);
      });

      _tmpl.find(".end-time").timepicker({
        minuteStep: 1,
        showSeconds: true,
        showMeridian: false,
        defaultTime: false
      });

      _tmpl.find(".start-time").on("change", function () {
        // the timepicker plugin doesn't have a change event handler
        // so we need to wait a bit to handle in with the default field event
        window.setTimeout(function () {
          rangeHandler(true)
        }, 200);
      });

      _tmpl.find(".end-time").on("change", function () {
        window.setTimeout(function () {
          rangeHandler(false)
        }, 200);
      });

      if (_minMoment.isValid()) {
        rangeHandler(true);
      }

      _tmpl.find(".facet-field-cnt.picker .facet-field-switch a").on("click", function(){
        _tmpl.find(".facet-field-cnt.custom").show();
        _tmpl.find(".facet-field-cnt.picker").hide();
      });

      _tmpl.find(".facet-field-cnt.custom .facet-field-switch a").on("click", function(){
        _tmpl.find(".facet-field-cnt.custom").hide();
        _tmpl.find(".facet-field-cnt.picker").show();
      });

      _tmpl.find(".start-date-custom").on("change", function () {
        _options.min(_tmpl.find(".start-date-custom").val());
        _options.start(_options.min());
      });

      _tmpl.find(".end-date-custom").on("change", function () {
        _options.max(_tmpl.find(".end-date-custom").val());
        _options.end(_options.max());
      });

      _tmpl.find(".interval-custom").on("change", function () {
        _options.gap(_tmpl.find(".interval-custom").val());
      });

      function matchIntervals(){
        if (_tmpl.find(".interval-select option[value='"+_options.gap()+"']").length > 0){
          _tmpl.find(".interval-select").val(_options.gap());
          _tmpl.find(".interval").hide();
        }
        else {
          _tmpl.find(".interval-select").val("");
          _tmpl.find(".interval").show();
        }
      }

      _tmpl.find(".interval-select").on("change", function () {
        if (_tmpl.find(".interval-select").val() == ""){
          _tmpl.find(".interval").show();
        }
        else {
          _tmpl.find(".interval").hide();
          _options.gap(_tmpl.find(".interval-select").val());
          _tmpl.find(".interval").val(_options.gap());
        }
      });

      _tmpl.find(".interval").on("change", function () {
        if (_tmpl.find(".interval-select").val() == ""){
          _options.gap(_tmpl.find(".interval").val());
          _tmpl.find(".interval-custom").val(_options.gap());
        }
      });

      function rangeHandler(isStart) {
        var startDate = moment(_tmpl.find(".start-date").val() + " " + _tmpl.find(".start-time").val(), DATETIME_FORMAT);
        var endDate = moment(_tmpl.find(".end-date").val() + " " + _tmpl.find(".end-time").val(), DATETIME_FORMAT);
        if (startDate.valueOf() > endDate.valueOf()) {
          if (isStart) {
            _tmpl.find(".end-date").val(startDate.format(DATE_FORMAT));
            _tmpl.find(".end-date").datepicker('setValue', startDate.format(DATE_FORMAT));
            _tmpl.find(".end-date").data("original-val", _tmpl.find(".end-date").val());
            _tmpl.find(".end-time").val(startDate.format(TIME_FORMAT));
          }
          else {
            if (_tmpl.find(".end-date").val() == _tmpl.find(".start-date").val()) {
              _tmpl.find(".end-time").val(startDate.format(TIME_FORMAT));
              _tmpl.find(".end-time").data("timepicker").setValues(startDate.format(TIME_FORMAT));
            }
            else {
              _tmpl.find(".end-date").val(_tmpl.find(".end-date").data("original-val"));
              _tmpl.find(".end-date").datepicker("setValue", _tmpl.find(".end-date").data("original-val"));
            }
            // non-sticky error notification
            $.jHueNotify.notify({
              level:"ERROR",
              message:"${ _("The end cannot be before the starting moment") }"
            });
          }
        }
        else {
          _tmpl.find(".end-date").data("original-val", _tmpl.find(".end-date").val());
          _tmpl.find(".start-date").datepicker("hide");
          _tmpl.find(".end-date").datepicker("hide");
        }

        var _calculatedStartDate = moment(_tmpl.find(".start-date").val() + " " + _tmpl.find(".start-time").val(), DATETIME_FORMAT).utc();
        var _calculatedEndDate = moment(_tmpl.find(".end-date").val() + " " + _tmpl.find(".end-time").val(), DATETIME_FORMAT).utc();

        _options.min(_calculatedStartDate.format("YYYY-MM-DD[T]HH:mm:ss[Z]"));
        _options.start(_options.min());
        _options.max(_calculatedEndDate.format("YYYY-MM-DD[T]HH:mm:ss[Z]"));
        _options.end(_options.max());

        _tmpl.find(".start-date-custom").val(_options.min());
        _tmpl.find(".end-date-custom").val(_options.max());

        var _opts = [];
        // hide not useful options from interval
        if (_calculatedEndDate.diff(_calculatedStartDate, 'minutes') > 1 && _calculatedEndDate.diff(_calculatedStartDate, 'minutes') <= 60){
          _opts = enableOptions("200MILLISECONDS", "1SECONDS", "1MINUTES", "5MINUTES", "10MINUTES", "30MINUTES");
        }
        if (_calculatedEndDate.diff(_calculatedStartDate, 'hours') > 1 && _calculatedEndDate.diff(_calculatedStartDate, 'hours') <= 12){
          _opts = enableOptions("5MINUTES", "10MINUTES", "30MINUTES", "1HOURS", "3HOURS");
        }
        if (_calculatedEndDate.diff(_calculatedStartDate, 'hours') > 12 && _calculatedEndDate.diff(_calculatedStartDate, 'hours') < 36){
          _opts = enableOptions("10MINUTES", "30MINUTES", "1HOURS", "3HOURS", "12HOURS");
        }
        if (_calculatedEndDate.diff(_calculatedStartDate, 'days') > 1 && _calculatedEndDate.diff(_calculatedStartDate, 'days') <= 7){
          _opts = enableOptions("30MINUTES", "1HOURS", "3HOURS", "12HOURS", "1DAYS");
        }
        if (_calculatedEndDate.diff(_calculatedStartDate, 'days') > 7 && _calculatedEndDate.diff(_calculatedStartDate, 'days') <= 14){
          _opts = enableOptions("3HOURS", "12HOURS", "1DAYS");
        }
        if (_calculatedEndDate.diff(_calculatedStartDate, 'days') > 14 && _calculatedEndDate.diff(_calculatedStartDate, 'days') <= 31){
          _opts = enableOptions("12HOURS", "1DAYS", "7DAYS");
        }
        if (_calculatedEndDate.diff(_calculatedStartDate, 'months') > 1){
          _opts = enableOptions("1DAYS", "7DAYS", "1MONTHS");
        }
        if (_calculatedEndDate.diff(_calculatedStartDate, 'months') > 6){
          _opts = enableOptions("1DAYS", "7DAYS", "1MONTHS", "6MONTHS");
        }
        if (_calculatedEndDate.diff(_calculatedStartDate, 'months') > 12){
          _opts = enableOptions("7DAYS", "1MONTHS", "6MONTHS", "1YEARS");
        }

        $(".interval-select").html(renderOptions(_opts));

        matchIntervals();
      }
    }
  }


  ko.bindingHandlers.augmenthtml = {
    render: function (element, valueAccessor, allBindingsAccessor, viewModel) {
      var _val = ko.unwrap(valueAccessor());
      var _enc = $("<span>").html(_val);
      if (_enc.find("style").length > 0){
        var parser = new less.Parser();
        $(_enc.find("style")).each(function(cnt, item){
          var _less = "#result-container {" + $(item).text() + "}";
          try {
            parser.parse(_less, function (err, tree) {
              $(item).text(tree.toCSS());
            });
          }
          catch (e){}
        });
        $(element).html(_enc.html());
      }
      else {
        $(element).html(_val);
      }
    },
    init: function (element, valueAccessor, allBindingsAccessor, viewModel) {
      ko.bindingHandlers.augmenthtml.render(element, valueAccessor, allBindingsAccessor, viewModel);
    },
    update: function (element, valueAccessor, allBindingsAccessor) {
      ko.bindingHandlers.augmenthtml.render(element, valueAccessor, allBindingsAccessor, viewModel);
    }
  }

  ko.bindingHandlers.clearable = {
    init: function (element, valueAccessor, allBindingsAccessor, viewModel) {
      var _el = $(element);
      function tog(v) {
        return v ? "addClass" : "removeClass";
      }
      _el.addClass("clearable");
      _el.on("input",function () {
        _el[tog(this.value)]("x");
        valueAccessor()(_el.val());
      }).on("mousemove", function (e) {
        _el[tog(this.offsetWidth - 18 < e.clientX - this.getBoundingClientRect().left)]("onX");
      }).on("click", function (e) {
        if (this.offsetWidth - 18 < e.clientX - this.getBoundingClientRect().left){
          _el.removeClass("x onX").val("");
          valueAccessor()("");
        }
      });
    },
    update: function (element, valueAccessor, allBindingsAccessor) {
      $(element).val(ko.unwrap(valueAccessor()));
    }
  }

  ko.bindingHandlers.spinedit = {
    init: function (element, valueAccessor, allBindingsAccessor, viewModel) {
      $(element).spinedit({
        minimum: 0,
        maximum: 10000,
        step: 5,
        value: ko.unwrap(valueAccessor()),
        numberOfDecimals: 0
      });
      $(element).on("valueChanged", function (e) {
        valueAccessor()(e.value);
      });
    },
    update: function (element, valueAccessor, allBindingsAccessor) {
      $(element).spinedit("setValue", ko.unwrap(valueAccessor()));
    }
  }

  ko.bindingHandlers.codemirror = {
    init: function (element, valueAccessor, allBindingsAccessor, viewModel) {
      var options = $.extend(valueAccessor(), {});
      var editor = CodeMirror.fromTextArea(element, options);
      element.editor = editor;
      editor.setValue(options.data());
      editor.refresh();
      var wrapperElement = $(editor.getWrapperElement());

      $(document).on("refreshCodemirror", function(){
        editor.setSize("100%", 300);
        editor.refresh();
      });

      $(document).on("addFieldToSource", function(e, field){
        if ($(element).data("template")){
          editor.replaceSelection("{{" + field.name() + "}}");
        }
      });

      $(document).on("addFunctionToSource", function(e, fn){
        if ($(element).data("template")){
          editor.replaceSelection(fn);
        }
      });

      $(".chosen-select").chosen({
        disable_search_threshold: 10,
        width: "75%"
      });
      $('.chosen-select').trigger('chosen:updated');

      var sourceDelay = -1;
      editor.on("change", function (cm) {
        clearTimeout(sourceDelay);
        var _cm = cm;
        sourceDelay = setTimeout(function () {
          valueAccessor().data(_cm.getValue());
          if ($(".widget-html-pill").parent().hasClass("active")){
            $("[contenteditable=true]").html(stripHtmlFromFunctions(valueAccessor().data()));
          }
        }, 100);
      });

      ko.utils.domNodeDisposal.addDisposeCallback(element, function () {
        wrapperElement.remove();
      });
    },
    update: function (element, valueAccessor, allBindingsAccessor) {
      var editor = element.editor;
      editor.refresh();
    }
  };

  var _query = ${ query | n,unicode };
  if (window.location.hash != ""){
    if (window.location.hash.indexOf("collection") == -1){
      try {
        var _decompress = LZString.decompressFromBase64(window.location.hash.substr(1));
        if (_decompress != null && $.trim(_decompress) != ""){
          _query = ko.mapping.fromJSON(LZString.decompressFromBase64(window.location.hash.substr(1)));
        }
      }
      catch (e){}
    }
  }

  viewModel = new SearchViewModel(${ collection.get_c(user) | n,unicode }, _query, ${ initial | n,unicode });
  ko.applyBindings(viewModel);


  viewModel.init(function(data){
    $(".chosen-select").trigger("chosen:updated");
  });
  viewModel.isRetrievingResults.subscribe(function(value){
    if (!value){
      resizeFieldsList();
    }
  });

  viewModel.isEditing.subscribe(function(value){
    if (value){
      window.setTimeout(function(){
        if ($(".slider-cnt").length > 0 && $(".slider-cnt").data("slider")){
          $(".slider-cnt").slider("redraw");
        }
      }, 300);
    }
  });

  $("#addFacetDemiModal").on("hidden", function () {
    if (typeof selectedWidget.hasBeenSelected == "undefined"){
      addFacetDemiModalFieldCancel();
    }
  });

});

  function showShareModal() {
    if (window.location.search.indexOf("collection") == -1 && window.location.hash.indexOf("collection") == -1) {
      $(document).trigger("error", "${_('The current collection must be saved to be shared.')}");
    }
    else {
      $("#shareModal input[type='text']").on("focus", function () {
        this.select();
      });
      var _search = window.location.search;
      var _pathname = window.location.pathname;
      if (_pathname.indexOf("${ url('search:new_search') }") > -1) {
        _pathname = "${ url('search:index') }";
      }
      if (_search == "" && window.location.hash.indexOf("collection") > -1) {
        _search = "?" + window.location.hash.substr(1);
      }

      if (_search != "") {
        $("#shareModal input[type='text']").val(window.location.origin + _pathname + _search + "#" + LZString.compressToBase64(ko.mapping.toJSON(viewModel.query))).focus();
        $("#shareModal").modal("show");
      }
      else {
        $(document).trigger("error", "${_('The current collection cannot be shared.')}");
      }
    }
  }

  function toggleGridFieldsSelection() {
    if (viewModel.collection.template.fields().length > 0) {
      viewModel.collection.template.fieldsSelected([])
    }
    else {
      var _fields = [];
      $.each(viewModel.collection.fields(), function (index, field) {
        _fields.push(field.name());
      });
      viewModel.collection.template.fieldsSelected(_fields);
    }
  }

  var selectedWidget = null;
  function showAddFacetDemiModal(widget) {
    if (["resultset-widget", "html-resultset-widget", "filter-widget"].indexOf(widget.widgetType()) == -1) {
      viewModel.collection.template.fieldsModalFilter("");
      viewModel.collection.template.fieldsModalType(widget.widgetType());
      viewModel.collection.template.fieldsModalFilter.valueHasMutated();
      $('#addFacetInput').typeahead({
          'source': viewModel.collection.template.availableWidgetFieldsNames(),
          'updater': function(item) {
              addFacetDemiModalFieldPreview({'name': function(){return item}});
              return item;
           }
      });
      selectedWidget = widget;
      $("#addFacetDemiModal").modal("show");
      $("#addFacetDemiModal input[type='text']").focus();
    }
  }


  function addFacetDemiModalFieldPreview(field) {
    var _existingFacet = viewModel.collection.getFacetById(selectedWidget.id());
    if (selectedWidget != null) {
      selectedWidget.hasBeenSelected = true;
      selectedWidget.isLoading(true);
      viewModel.collection.addFacet({'name': field.name(), 'widget_id': selectedWidget.id(), 'widgetType': selectedWidget.widgetType()});
      if (_existingFacet != null) {
        _existingFacet.label(field.name());
        _existingFacet.field(field.name());
      }
      $("#addFacetDemiModal").modal("hide");
    }
  }

  function addFacetDemiModalFieldCancel() {
    viewModel.removeWidget(selectedWidget);
  }

  $(document).on("setResultsHeight", function () {
    $("#result-main").height($("#result-container").outerHeight() + 100);
  });

  function highlightColumn(column) {
    var _colName = $.trim(column.name());
    if (viewModel.collection.template.fieldsSelected.indexOf(_colName) > -1) {
      var _t = $("#result-container");
      var _col = _t.find("th").filter(function () {
        return $.trim($(this).text()) == _colName;
      });
      if (_t.find("tr td:nth-child(" + (_col.index() + 1) + ").columnSelected").length == 0) {
        _t.find(".columnSelected").removeClass("columnSelected");
        _t.find("tr td:nth-child(" + (_col.index() + 1) + ")").addClass("columnSelected");
        _t.parent().animate({
          scrollLeft: _t.find("tr td:nth-child(" + (_col.index() + 1) + ")").position().left + _t.parent().scrollLeft() - _t.parent().offset().left - 30
        }, 300);
      }
      else {
        _t.find(".columnSelected").removeClass("columnSelected");
      }
    }
  }


</script>


${ commonfooter(messages) | n,unicode }
