
// Make 'earth' global
//earth = false;
//layer = false;

window.earth = false;
window.layer = false;
window.markers = false;

(function($){

    $.fn.add_markers = function() {
        $.ajax({
            type: "GET",
            url: "../locations.xml",
            dataType: "xml",
            success: function(xml) {
                window.markers = $(xml).find("city");
                $.each($(xml).find("city"), function(k, v) {
                    var geo = [parseFloat($(v).find("lat").text()),
                               parseFloat($(v).find("lon").text())];
                    var name = $(v).find("name").text();
                    var country = $(v).find("country").text();

                    /* Generate marker */
                    var m = WE.marker(geo)
                    var elem = $(m.element).find(".we-pm-icon");
                    $(elem).attr("name", name).attr("country", country);
                    m.addTo(window.earth);
                });
            },
            error: function() {
                alert("Ups, problems loading locations.xml");
            }
        });
    }



    /* Marker interaction */
    $.fn.init_navigation_years = function() {
        var target = $("#years");
        for (i = 1979; i < 2022; i++) {
            $("<option value=\"" + i + "\">" + i + "</option>").appendTo(target);
        }
        $(target).find("option:last-child").prop("selected", true);
        /* Adding functionality */
        $(target).change(function(x) {
            $.fn.initialize_globe($.fn.get_product(), false, false);
        });
    };

    $.fn.init_navigation_months = function() {
        var vals = ["JAN", "FEB", "MAR", "APR", "MAI", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        var target = $("#months");
        for (i = 0; i < vals.length; i++) {
            $("<li value=\"" + (i + 1) + "\">" + vals[i] + "</li>").appendTo(target);
        }
        $(target).find("li[value='10']").addClass("active");
        console.log("months fertig")
        /* Functionality */
        $("#months li").click(function() {
            var oval = $("#months li.active").prop("value");
            var nval = $(this).prop("value");
            if (oval != nval) {
                $("#months li.active").removeClass("active");
                $(this).addClass("active");
                $.fn.initialize_globe($.fn.get_product(), false, false);
            }
        });

        $(target).change(function(x) {
            $.fn.initialize_globe($.fn.get_product(), false, false);
        });
    }

    $.fn.get_product = function() {
        var prod = $("ul#product li.active").attr("product")
        if (prod === undefined) {
            var tmp = $("ul#product li:first-child")
            prod = $(tmp).attr("product")
            $(tmp).addClass("active")
        }
        var year = $("#years").val();
        var mon  = parseInt($("#months > li.active").prop("value"));
        if (mon < 10) { mon = "0" + mon; }
        return(prod + "/" + year + mon);
    }

    $.fn.initialize_globe = function(product, position, zoom) {
        if (window.earth === false) {
            window.earth = new WE.map('earth-div',
                                      atmosphere = true,
                                      draggin = true,
                                      tilting = false,
                                      zooming = true);
            // Appending markers
            $.fn.add_markers();
            var marker = WE.marker([0, 0]);
            $(marker.element).find(".we-pm-icon").attr("marker_id", 10);
            marker.addTo(earth);

            var m2 = WE.marker([10, 10]);
            $(m2.element).find(".we-pm-icon").attr("marker_id", 222);
            var m3 = WE.marker([20, 20]);
            $(m3.element).find(".we-pm-icon").attr("marker_id", 333);
            m2.addTo(earth);
            m3.addTo(earth);


            window.marker = marker
            //marker.bindPopup("<b>Innschpruck</b>");
        }

        var domain   = window.location.origin
        var pathname = window.location.pathname
        if (pathname == "/") { pathname = "" }
        var tile_url = domain + pathname + "/tiles/" + product + "/{z}/{x}/{y}.png"

        if (window.layer !== false) {
            console.log('I have a layer');
            window.layer.removeFrom(window.earth);
        }

        window.layer = WE.tileLayer(tile_url, {attribution: "DiSC", minZoom: 1, maxZoom: 3});
        window.layer.addTo(earth);

        // Setting position and zoom if required/requested
        if (position !== false) { window.earth.setPosition(position[0], position[1]); }
        if (zoom !== false)     { window.earth.setZoom(zoom) };
        return earth
    }

    $(document).on("click", ".we-pm-icon", function() {
        alert($(this).attr("name"));
    });

    // On document ready: Initialize globe
    $(document).ready(function() {

        $.fn.init_navigation_years();
        $.fn.init_navigation_months();

        var product = $.fn.get_product()

        /* Adjust earth-div-wrapper first */
        $("#earth-div-wrapper").animate({"height": window.innerHeight + "px"}, 0, function() {
            $("#earth-div").animate({"height": "100%", "width": "100%"}, 0, function() {
            earth = $.fn.initialize_globe(product, position = [47.5, 11.3], zoom = 2)
            });

        });

        // Manual navigation to change the product
        $("#product li").on("click", function(x) {
            $("#product li.active").removeClass("active");
            $(this).addClass("active");

            // 'earth' is global, take current position and zoom
            // for seamless transition to new layer.
            earth = $.fn.initialize_globe($.fn.get_product(), false, false);
        });
        $("#yearmon li").on("click", function(x) {
            $("#yearmon li.active").removeClass("active");
            $(this).addClass("active");

            // 'earth' is global, take current position and zoom
            // for seamless transition to new layer.
            earth = $.fn.initialize_globe($.fn.get_product(), false, false);
        });

    });
})(jQuery);
