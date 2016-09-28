(function ($) {
  var ValueStorage = {
    store: {},
    set: function (key, value) {
      var item = $('[name="' + key + '"]'), val;
      this.store[key] = value;
      if (item.data('type') === 'boolean') {
        item.prop('checked', value);
      } else if (item.data('type') == 'json') {
        item.val(JSON.stringify(value));
      }  else {
        item.val(value);
      }

      /* extra cases */
      if (key === 'webserver.extra_config_ssl' && value == 'true') {
        this.store[key] = true;
      }

      JSONBuilder.build(this.store);
    },
    get: function (key) {
      var index, pair, out;
      if (key.match(/\./)) {
        return this.store[key];
      }
      out = {};
      for (index in this.store) {
        if (this.store.hasOwnProperty(index)) {
          if (index.match(/\./)) {
            pair = index.split('.');
            if (pair[0] === key) {
              out[pair[1]] = this.store[index];
            }
          } else {
            if (index === key) {
              out = this.store[key];
            }
          }
        }
      }
      return out;
    },
    reset: function () {
      this.store = {};
      JSONBuilder.restoreDefaults();
    }
  };

  var FormBuilder = {
    container: $('.builder--form'),
    schema: {},
    init: function (schema) {
      this.schema = schema;
      return this;
    },
    build: function () {
      var group, field, currentGroup, data = this.schema;
      if (!this.container.length > 0) {
        return;
      }
      for (group in this.schema) {
        if (this.schema.hasOwnProperty(group)) {
          if (currentGroup !== group) {
            this.buildHeader(group);
            currentGroup = group;
          }
          for (field in this.schema[group]) {
            if (this.schema[group].hasOwnProperty(field)) {
              this['build' + this.schema[group][field]['type'][0].toUpperCase() + this.schema[group][field]['type'].substring(1)](group, field);
            }
          }
        }
      }

      JSONBuilder.restoreDefaults();
    },
    seeMore: function (item) {
      if (!item['url']) {
        return '';
      }
      return ' <a href="' + item['url'] + '" target="_blank">See&nbsp;more.</a>';
    },
    buildHeader: function (value) {
      var head = value[0].toUpperCase() + value.substring(1);
      head = '<h3>' + head + '</h3>';
      if (value === 'database' || value === 'scm') {
        head += '<div class="bs-callout bs-callout-danger"><h4>This group works out of the box</h4><p>If you configured your ' + value + ' in OpsWorks, you don\'t have to change anything here. Refer <a href="https://github.com/ajgon/opsworks_ruby">documentation</a> for more details.</p></div>';
      }
      this.container.append($(head));
    },
    buildBoolean: function (group, field) {
      var item = this.schema[group][field];
      var node = $('<div class="form-group"><label class="col-sm-5 control-label" for="' + group + '_' + field + '">' + field + '</label> <div class="col-sm-7"><input type="checkbox" data-type="boolean" name="' + group + '.' + field + '" id="' + group + '_' + field  + '"> <p class="help-block">' + item['description'] + this.seeMore(item) + '</p></div></div>');
      this.container.append(node);
      node.find('input').change(function (e) {
        ValueStorage.set($(this).attr('name'), $(this).prop('checked'));
      });
    },
    buildFloat: function (group, field) {
      var item = this.schema[group][field];
      var node = $('<div class="form-group"><label class="col-sm-5 control-label" for="' + group + '_' + field + '">' + field + '</label> <div class="col-sm-7"><input type="number" data-type="float" step="0.1" name="' + group + '.' + field + '" class="form-control" id="' + group + '_' + field + '"> <p class="help-block">' + item['description'] + this.seeMore(item) + '</p></div></div>');
      this.container.append(node);
      var self = this;
      node.find('input').change(function (e) { self.onTextChange.call(this, e, 'float') });
    },
    buildInteger: function (group, field) {
      var item = this.schema[group][field];
      var node = $('<div class="form-group"><label class="col-sm-5 control-label" for="' + group + '_' + field + '">' + field + '</label> <div class="col-sm-7"><input type="number" data-type="integer" step="1" name="' + group + '.' + field + '" class="form-control" id="' + group + '_' + field + '"> <p class="help-block">' + item['description'] + this.seeMore(item) + '</p></div></div>');
      this.container.append(node);
      var self = this;
      node.find('input').change(function (e) { self.onTextChange.call(this, e, 'integer') });
    },
    buildString: function (group, field) {
      var self = this;
      var item = this.schema[group][field], node, nodeData, value;
      if (item['values']) {
        nodeData = '<div class="form-group"><label class="col-sm-5 control-label" for="' + group + '_' + field + '">' + field + '</label> <div class="col-sm-7"><select data-type="string" name="' + group + '.' + field + '" class="form-control" id="' + group + '_' + field + '">';
        for(value in item['values']) {
          if (item['values'].hasOwnProperty(value)) {
            nodeData += '<option value="' + item['values'][value] + '">' + item['values'][value] + '</option>';
          }
        }
        nodeData += '</select><p class="help-block">' + item['description'] + this.seeMore(item) + '</p></div></div>';
        node = $(nodeData);
      } else {
        node = $('<div class="form-group"><label class="col-sm-5 control-label" for="' + group + '_' + field + '">' + field + '</label> <div class="col-sm-7"><input type="text" data-type="string" name="' + group + '.' + field + '" class="form-control" id="' + group + '_' + field + '"> <p class="help-block">' + item['description'] + this.seeMore(item) + '</p></div></div>');
      }
      this.container.append(node);
      var self = this;
      node.find('input, select').change(function (e) { self.onTextChange.call(this, e) });
      if (field === 'adapter') {
        node.find('select').change(function (e) {
          self.showDependants(group);
        });
      }
    },
    buildText: function (group, field, type) {
      var item = this.schema[group][field];
      var node = $('<div class="form-group"><label class="col-sm-5 control-label" for="' + group + '_' + field + '">' + field + '</label> <div class="col-sm-7"><textarea data-type="' + item['type'] + '" name="' + group + '.' + field + '" class="form-control" id="' + group + '_' + field + '"></textarea> <p class="help-block">' + item['description'] + this.seeMore(item) + '</p></div></div>');
      var nodeType = type || 'text';
      this.container.append(node);
      var self = this;
      node.find('textarea').change(function (e) { self.onTextChange.call(this, e, nodeType) });
    },
    buildJson: function (group, field) {
      this.buildText(group, field, 'json');
    },
    showDependants: function (group) {
      var field, data = ValueStorage.get(group);
      for (field in this.schema[group]) {
        if (this.schema[group].hasOwnProperty(field) && this.schema[group][field]['depends']) {
          $('[name="' + group + '.' + field + '"]').closest('.form-group').toggle(this.schema[group][field]['depends'].indexOf(data.adapter) !== -1)
        }
      }
    },
    refresh: function() {
      var group;
      for (group in this.schema) {
        if (this.schema.hasOwnProperty(group)) {
          this.showDependants(group);
        }
      }
    },
    onTextChange: function (e, type) {
      var val = $(this).val();
      if (type === 'float') {
        val = parseFloat(val, 10);
      } else if (type === 'integer') {
        val = parseInt(val, 10);
      } else if (type === 'json') {
        try {
          val = JSON.parse(val);
        } catch (err) {
          val = {};
        }
      }
      ValueStorage.set($(this).attr('name'), val);
    }
  };

  var JSONBuilder = {
    flask: new CodeFlask(),
    schema: {},
    output: {},
    init: function (schema) {
      var self = this;
      this.schema = schema;
      this.flask.run('#builder-output', { language: 'json' });
      $('.CodeFlask__textarea').change(function (e) {
        var item = $('#builder-output');
        if (!item.data('auto-update')) {
          self.observe.call(item[0], $(this).val());
        }
      });
      $('#application_name').change(function (e) {
        JSONBuilder.build(ValueStorage.store);
      });
      $('#code-window-container').sticky({bottomSpacing: 364, responsiveWidth: true});
      $('#code-reset').click(function (e) {
        e.preventDefault();
        ValueStorage.reset();
      });
      new Clipboard('#code-ctrl-c', { target: function () { return $('.CodeFlask__textarea')[0]; } });
    },
    restoreDefaults: function () {
      for (group in this.schema) {
        if (this.schema.hasOwnProperty(group)) {
          for (field in this.schema[group]) {
            if (this.schema[group].hasOwnProperty(field)) {
              ValueStorage.set(group + '.' + field, this.schema[group][field]['default']);
            }
          }
          FormBuilder.showDependants(group);
        }
      }
    },
    build: function (data) {
      var key, pair, output, $appName = $('#application_name');
      output = {};
      for(key in data) {
        if(data.hasOwnProperty(key)) {
          pair = key.split('.');
          if (!this.schema[pair[0]] || !this.schema[pair[0]][pair[1]] || (this.schema[pair[0]][pair[1]]['default'] !== data[key] && data[key] !== undefined && data[key] !== '' && !($.isPlainObject(data[key]) && $.isEmptyObject(data[key])))) {
            output[pair[0]] = output[pair[0]] || {};
            if (pair[1]) {
              output[pair[0]][pair[1]] = data[key];
            } else {
              output[pair[0]] = data[key];
            }
          }
        }
      }
      this.output = {};
      if (!$appName.val()) {
        $appName.val('application_short_name');
      }
      this.output[$appName.val()] = output;
      $('#builder-output').data('auto-update', true);
      this.flask.update(JSON.stringify(this.output, null, 2));
      FormBuilder.refresh();
      $('#builder-output').data('auto-update', false);
    },
    observe: function (json) {
      var input, i, group, field, item, appName;
      JSONBuilder.restoreDefaults();
      try {
        input = JSON.parse(json);
        appName = Object.keys(input)[0];
        input = input[appName];
        $('#application_name').val(appName);
      } catch(err) {
        input = {};
      }
      for (group in input) {
        if (input.hasOwnProperty(group)) {
          for (field in input[group]) {
            if (input[group].hasOwnProperty(field)) {
              if (Object.keys(JSONBuilder.schema).indexOf(group) !== -1) {
                ValueStorage.set(group + '.' + field, input[group][field]);
              } else {
                ValueStorage.set(group, input[group]);
              }
            }
          }
        }
      }
    }
  };

  var JSONBuilderApp = {
    build: function () {
      $.getJSON(BASE_URL + '/data/schema.json', function (data) {
        JSONBuilder.init(data);
        FormBuilder.init(data).build();
      });
    }
  };

  JSONBuilderApp.build();

  window.vs = ValueStorage;
}(jQuery));
