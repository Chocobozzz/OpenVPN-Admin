/**
* SlickGrid Enhancement Pager
*
* An easy-to-use slickgrid pager.
* https://github.com/kingleema/SlickGridEnhancementPager
* Released under the MIT license.
* 
* Copyright 2012 KingleeMa <https://github.com/kingleema>
*
*/
(function ($) {
    function EnhancementPager(paramObj) {
        var waiting = parseInt(paramObj.waiting);
        if (isNaN(waiting)) {
            waiting = 30000;
        }
        
        var param = { pageSize: 10, pageIndex: 1 };
        
        for (var attrname in paramObj.params) {
            param[attrname] = paramObj.params[attrname];
        }
        
        $.ajax({
            url: paramObj.remoteUrl,
            type: 'POST',
            cache: false,
            data: param ,
            dataType: "text",
            crossDomain: false,
            timeout: waiting,
            beforeSend: function() {
                paramObj.container.html('<span class="dataloading">&nbsp;</span>');
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                paramObj.container.html('<span style="position:absolute;top:5px;left:5px;color:red;">Error!&nbsp;' + errorThrown + '</span>');
            },
            success: function (data) {
                var total = $.evalJSON(data).Total;
                pagecount = parseInt(Math.floor(parseFloat(total / 10)) + 1);
                initPager(pagecount, paramObj.pagerType, paramObj.trans, waiting);
                
                getData(1, paramObj.remoteUrl, paramObj.pagerType, paramObj.params, waiting);
            }
        });
        
        function initPager(pagecount, pagertype, trans, waiting) {
          paramObj.container.html('');
          $('<span class="perpage" title="Records count of per page"><select class="recordsperpage">\
              <option value="10">10</option>\
              <option value="25">25</option>\
              <option value="50">50</option>\
              <option value="100">100</option>\
          </select></span>\
          <span class="spacer">&nbsp;</span>\
          <span class="pagelabel" style="vertical-align: middle;">Page</span>\
          <input class="currentpage" title="Current Page" type="text" value="1" style="vertical-align: middle;width:7px" />\
          <span style="vertical-align: middle;">&nbsp;/&nbsp;</span>\
          <span id="totalpages" style="vertical-align: middle;">#</span>\
          <span class="spacer">&nbsp;</span>\
          <a id="dataloading" href="javascript:;" class="button-base-class refresh" title="Refresh"></a>\
          <span class="spacer">&nbsp;</span>\
          <span class="recordstate"><span class="recordstatelabel">Display</span>&nbsp;<span id="recordsegment"></span>&nbsp;/&nbsp;<span id="totalrecords"></span></span>\
          <a href="javascript:;" class="button-base-class currentrecords" title="Show/Hide Current Records State"></a>').appendTo(paramObj.container);
            $('.currentpage').keydown(function (e) {
                if (e.keyCode == 13) {
                    var changedvalue = 1;
                    if (isNaN(parseInt($(".currentpage").val()))) {
                        $(".currentpage").val(changedvalue);
                    } else {
                        changedvalue = parseInt($(".currentpage").val());
                        if (changedvalue < 1) {
                            changedvalue = 1;
                        }
                        if (changedvalue > parseInt($("#totalpages").text())) {
                            changedvalue = parseInt($("#totalpages").text());
                        }
                        $('.currentpage').val(changedvalue);
                    }
                    getData(changedvalue, paramObj.remoteUrl, pagertype, paramObj.params, waiting);
                }
            });
            if (pagertype == "slider") {
                $('<span class="button-base-class pageminus" title="Previous Page">&nbsp;</span>\
               <span class="pagerslider"></span>\
               <span class="button-base-class pageplus" title="Next Page">&nbsp;</span>\
               <span class="spacer">&nbsp;</span>').insertBefore($('.pagelabel'));
                if (trans !== null && trans !== undefined) {
                    $.each(trans, function (k, v) {
                        if (k != "resultset_first" && k != "resultset_prev" && k != "resultset_next" && k != "resultset_last") {
                            if (k == "pagelabel" || k == "recordstatelabel") {
                                $('.' + k).text(v);
                            } else {
                                $('.' + k).attr("title", v);
                            }
                        }
                    });
                }
                $(".pagerslider").slider({
                    range: "min",
                    value: 1,
                    step: 1,
                    min: 1,
                    max: pagecount,
                    slide: function (event, ui) {
                        $(".currentpage").css("width", ui.value.toString().length * 7 + "px");
                        var pd = ui.value;
                        $(".currentpage").val(pd);
                    },
                    stop: function (event, ui) {
                        var changedvalue = ui.value;
                        getData(changedvalue, paramObj.remoteUrl, pagertype, paramObj.params, waiting);
                    }
                });
                $(".pageplus").click(function () {
                    if (isNaN(parseInt($(".currentpage").val()))) {
                        $(".currentpage").val(1);
                    }
                    var changedvalue = parseInt($(".currentpage").val()) + 1;
                    if (changedvalue > parseInt($("#totalpages").text())) {
                        changedvalue = parseInt($("#totalpages").text());
                    }
                    getData(changedvalue, paramObj.remoteUrl, pagertype, paramObj.params, waiting);
                });
                $(".pageminus").click(function () {
                    if (isNaN(parseInt($(".currentpage").val()))) {
                        $(".currentpage").val(1);
                    }
                    var changedvalue = parseInt($(".currentpage").val()) - 1;
                    if (changedvalue < 1) {
                        changedvalue = 1;
                    }
                    getData(changedvalue, paramObj.remoteUrl, pagertype, paramObj.params, waiting);
                });
            } else {
                $('<a href="javascript:;" class="button-base-class resultset_first" title="First Page"></a>\
               <a href="javascript:;" class="button-base-class resultset_prev" title="Previous Page"></a>\
               <span class="spacer">&nbsp;</span>').insertBefore($('.pagelabel'));
                $('<span class="spacer">&nbsp;</span>\
               <a href="javascript:;" class="button-base-class resultset_next" title="Next Page"></a>\
               <a href="javascript:;" class="button-base-class resultset_last" title="Last Page"></a>').insertAfter($('#totalpages'));
                if (trans !== null && trans !== undefined) {
                    $.each(trans, function (k, v) {
                        if (k != "pageminus" && k != "pageplus") {
                            if (k == "pagelabel" || k == "recordstatelabel") {
                                $('.' + k).text(v);
                            } else {
                                $('.' + k).attr("title", v);
                            }
                        }
                    });
                }
                $(".resultset_first").click(function () {
                    var changedvalue = 1;
                    getData(changedvalue, paramObj.remoteUrl, pagertype, paramObj.params, waiting);
                });
                $(".resultset_prev").click(function () {
                    if (isNaN(parseInt($(".currentpage").val()))) {
                        $(".currentpage").val(1);
                    }
                    var changedvalue = parseInt($(".currentpage").val()) - 1;
                    if (changedvalue < 1) {
                        changedvalue = 1;
                    }
                    getData(changedvalue, paramObj.remoteUrl, pagertype, paramObj.params, waiting);
                });
                $(".resultset_next").click(function () {
                    if (isNaN(parseInt($(".currentpage").val()))) {
                        $(".currentpage").val(1);
                    }
                    var changedvalue = parseInt($(".currentpage").val()) + 1;
                    if (changedvalue > parseInt($("#totalpages").text())) {
                        changedvalue = parseInt($("#totalpages").text());
                    }
                    getData(changedvalue, paramObj.remoteUrl, pagertype, paramObj.params, waiting);
                });
                $(".resultset_last").click(function () {
                    var changedvalue = parseInt($("#totalpages").text());
                    getData(changedvalue, paramObj.remoteUrl, pagertype, paramObj.params, waiting);
                });
            }
            $('.recordsperpage').dropkick({
                change: function (value, label) {
                    var changedvalue = 1;
                    getData(changedvalue, paramObj.remoteUrl, pagertype, paramObj.params, waiting);
                }
            });
            $(".refresh").click(function () {
                if (isNaN(parseInt($(".currentpage").val()))) {
                    $(".currentpage").val(1);
                }
                var changedvalue = parseInt($(".currentpage").val());
                if (changedvalue < 1) {
                    changedvalue = 1;
                }
                if (changedvalue > parseInt($("#totalpages").text())) {
                    changedvalue = parseInt($("#totalpages").text());
                }
                getData(changedvalue, paramObj.remoteUrl, pagertype, paramObj.params, waiting);
            });
            $(".currentrecords").click(function () {
                $(".recordstate").toggle("fast");
            });
        }
        function getData(changedvalue, url, pagertype, params, waiting) {
            var pagesize = $('.recordsperpage').val();
            var pageindex = changedvalue;
            var postedData = {};
            postedData['pageSize'] = pagesize;
            postedData['pageIndex'] = pageindex;
            if (params !== null && params != undefined) {
                $.each(params, function (k, v) {
                    postedData[k] = v;
                });
            }
            //alert();
            $.ajax({
                url: url,
                type: 'POST',
                cache: false,
                dataType: "text",
                crossDomain: true,
                data: postedData,
                timeout: waiting,
                beforeSend: function() {
                    $("#dataloading").attr("disabled","disabled");
                    $('#dataloading').removeClass('refresh');
                    $('#dataloading').addClass('dataloading');
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    paramObj.container.html('<span style="position:absolute;top:5px;left:5px;color:red;">Error!&nbsp;' + errorThrown + '</span>');
                },
                success: function (data) {
                    var total = $.evalJSON(data).Total;
                    var rows = $.evalJSON($.evalJSON(data).Rows);
                    //alert(rows.user_id);
                    paramObj.datagrid.setData(rows);
                    paramObj.datagrid.render();
                    $(".currentpage").css("width", changedvalue.toString().length * 7 + "px");
                    $(".currentpage").val(changedvalue);
                    var currentvalue = changedvalue;
                    var pagesize = parseInt($('.recordsperpage').val());
                    var fromvalue = (currentvalue - 1) * pagesize + 1;
                    var tovalue = fromvalue + pagesize - 1;
                    if (tovalue > total) {
                        tovalue = total;
                    }
                    $("#recordsegment").text(fromvalue + "-" + tovalue);
                    $("#totalrecords").text(total);
                    var totalpages = parseInt(Math.floor(parseFloat(total / pagesize)) + 1);
                    $("#totalpages").text(totalpages);
                    if (pagertype == "slider") {
                        $(".pagerslider").slider("value", changedvalue);
                        $(".pagerslider").slider("option", "max", totalpages);
                    }
                    $("#dataloading").removeAttr("disabled");
                    $('#dataloading').removeClass('dataloading');
                    $('#dataloading').addClass('refresh');
                }
            });
        }
    }
    $.extend(true, window, { Slick: { Controls: { EnhancementPager: EnhancementPager}} });
})(jQuery);