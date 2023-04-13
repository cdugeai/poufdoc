(function (window, undefined) {

    function updateScroll() {
        Ps.update();
    }

    var _charts = [
		["test", 122, 158, "./resources/img/icon.png"],
	];

    var _charts_code = [];

    function fill_charts() {
        var _width = 0;
        for (var i = 0; i < _charts.length; i++) {
            if (_charts[i][1] > _width)
                _width = _charts[i][1];
        }

        _width += 20;

        var _space = 20;
        var _naturalWidth = window.innerWidth;

        var _count = ((_naturalWidth - _space) / (_width + _space)) >> 0;
        if (_count < 1)
            _count = 1;

        var _countRows = ((_charts.length + (_count - 1)) / _count) >> 0;

        var _html = "";
        var _index = 0;

        var _margin = (_naturalWidth - _count * (_width + _space)) >> 1;
        document.getElementById("main").style.marginLeft = _margin + "px";

        for (var _row = 0; _row < _countRows && _index < _charts.length; _row++) {
            _html += "<tr style='margin-left: " + _margin + "'>";

            for (var j = 0; j < _count; j++) {
                var _cur = _charts[_index];

                _html += "<td width='" + _width + "' height='" + _width + "' style='margin:" + (_space >> 1) + "'>";

                var _w = _cur[1];
                var _h = _cur[2];

                _html += ("<img id='chart" + _index + "' src=\"" + _cur[3] + "\" />");
                _html += ("<div class=\"noselect celllabel\">" + _cur[0] + "</div>");

                _html += "</td>";

                _index++;

                if (_index >= _charts.length)
                    break;
            }

            _html += "</tr>";
        }

        document.getElementById("main").innerHTML = _html;

        for (_index = 0; _index < _charts.length; _index++) {
            document.getElementById("chart" + _index).onclick = new Function("return window.chart_run(" + _index + ");");
        }

        updateScroll();
    }

    window.onresize = function () {
        fill_charts();
    };

    window.Asc.plugin.init = function (text) {
        var container = document.getElementById('scrollable-container-id');

        Ps = new PerfectScrollbar('#' + container.id, {});

        fill_charts();
    };

    window.Asc.plugin.button = function (id) {
        this.executeCommand("close", "");
    };

    window.chart_run = function (_index) {
        /*if (_charts_code[_index]) {
            window.Asc.plugin.info.recalculate = true;
            window.Asc.plugin.executeCommand("command", _charts_code[_index]);
            return;
        }

        window.Asc.plugin.callModule("./charts/" + _charts[_index][0] + "/script.txt", function(content){
        	_charts_code[_index] = content;
        });*/

        if (_charts[_index][0]) {
            Asc.scope.text = _charts[_index][0]; // export variable to plugin scope
            this.callCommand(function () {
                var oDocument = Api.GetDocument();
                var oParagraph = Api.CreateParagraph();
                oParagraph.AddText(Asc.scope.text); // or oParagraph.AddText(scope.text);
                oDocument.InsertContent([oParagraph]);
            }, true);
        }
    };

    window.Asc.plugin.onExternalMouseUp = function () {
        var evt = document.createEvent("MouseEvents");
        evt.initMouseEvent("mouseup", true, true, window, 1, 0, 0, 0, 0,
            false, false, false, false, 0, null);

        document.dispatchEvent(evt);
    };

})(window, undefined);