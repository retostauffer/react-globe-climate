
// Make 'earth' global
//earth = false;
//layer = false;

window.earth = false;
window.layer = false;
window.markers = false;

window.end_year = 2022; /* Last year to show up in dropdown menu */
window.end_month = 8;    /* Last selectable month in last year */

(function($){

    $.fn.add_markers = function() {
        $.ajax({
            type: "GET",
            url: "/locations.xml",
            dataType: "xml",
            success: function(xml) {
                window.markers = $(xml).find("city");
                $.each($(xml).find("city"), function(k, v) {
                    var geo = [parseFloat($(v).find("lat").text()),
                               parseFloat($(v).find("lon").text())];
                    var name = $(v).find("name").text();
                    var country = $(v).find("country").text();

                    /* Generate marker */
                    var m = WE.marker(geo);
                    var elem = $(m.element).find(".we-pm-icon");
                    $(elem).attr("name", name).attr("country", country);
                    $(elem).attr("style", "background-image: url('marker-icon.svg'); height: 10px; width: 10px; margin-left: 5px; margin-top: -5px;")
                    m.addTo(window.earth);
                });
            },
            error: function() {
                alert("Ups, problems loading locations.xml");
            }
        });
    }



    /* Setting up navigation year selector */
    $.fn.init_navigation_years = function() {
        var target = $("#years > select");
        for (i = 1979; i <= window.end_year; i++) {
            $("<option value=\"" + i + "\">" + i + "</option>").appendTo(target);
        }
        $(target).find("option:last-child").prop("selected", true);
        /* Adding functionality */
        $(target).change(function(x) {
            $.fn.initialize_globe($.fn.get_product(), false, false);
            $.fn.update_navigation_months();
        });
    };

    $.fn.init_navigation_months = function() {
        var vals = ["Januar", "Februar", "M&auml;rz",
                    "April", "Mai", "Juni", "Juli",
                    "August", "September", "Oktober",
                    "November", "Dezember"]
        var target = $("#months");
        for (i = 0; i < vals.length; i++) {
            $("<li value=\"" + (i + 1) + "\">" + vals[i] + "</li>").appendTo(target);
        }
        $(target).find("li[value='" + window.end_month + "']").addClass("active");
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

    $.fn.update_navigation_months = function() {
        /* Getting current year */
        var year = $("#years > select").val();
        console.log(year)

        /* If year < window.end_year: all active */
        if (year < window.end_year) {
            $.each($("#months li"), function() {
                $(this).removeClass("disabled")
            });
        /* Else disable months after window.end_month (int) */
        } else {
            $.each($("#months li"), function() {
                if (parseInt($(this).prop("value")) > window.end_month) {
                    $(this).addClass("disabled")
                }
            });
        }
    }

    $.fn.get_product = function(yearmon = true) {
        var prod = $("ul#product li.active").attr("product")
        if (prod === undefined) {
            var tmp = $("ul#product li:first-child")
            prod = $(tmp).attr("product")
            $(tmp).addClass("active")
        }
        var year = $("#years > select").val();
        var mon  = parseInt($("#months > li.active").prop("value"));
        if (mon < 10) { mon = "0" + mon; }
        if (yearmon) {
            return(prod + "/" + year + mon);
        } else {
            return(prod);
        }
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
            //var marker = WE.marker([0, 0]);
            //$(marker.element).find(".we-pm-icon").attr("marker_id", 10);
            //marker.addTo(earth);

            //var m2 = WE.marker([10, 10]);
            //$(m2.element).find(".we-pm-icon").attr("marker_id", 222);
            //var m3 = WE.marker([20, 20]);
            //$(m3.element).find(".we-pm-icon").attr("marker_id", 333);
            //m2.addTo(earth);
            //m3.addTo(earth);

            //window.marker = marker
            //marker.bindPopup("<b>Innschpruck</b>");
        }

        var domain   = window.location.origin
        var pathname = window.location.pathname
        if (pathname == "/") { pathname = "" }
        var tile_url = domain + pathname + "/tiles/" + product + "/{z}/{x}/{y}.png"

        if (window.layer !== false) {
            //////console.log('I have a layer');
            window.layer.removeFrom(window.earth);
        }

        window.layer = WE.tileLayer(tile_url, {attribution: "DiSC", minZoom: 1, maxZoom: 3});
        window.layer.addTo(earth);

        // Setting position and zoom if required/requested
        if (position !== false) { window.earth.setPosition(position[0], position[1]); }
        if (zoom !== false)     { window.earth.setZoom(zoom) };

        // Replace colormap
        var panel = $("#colormap-panel");
        $(panel).empty()
        $("<img src=\"images/legend_" + $.fn.get_product(false) + ".svg\" />").appendTo(panel)

        return earth
    }

    // Adjusting width of the 'detail panel'.
    // Default is 500px; we here change the CSS to 70% of window width.
    // Must also be triggered on window resize.
    $.fn.adjust_detail_panel_width = function() {
        var width = Math.round(parseFloat($(window).width()) / 2) + "px";
        $("#detail-panel").css("width", width);
    }

    // Interactivity for clicking on a position marker on the map
    $(document).on("click", ".we-pm-icon", function() {
        var city = $(this).attr("name");
        var country = $(this).attr("country");
        var width  = parseInt($(window).width()) - 200;
        var height = parseInt($(window).height()) - 200;
        $.modalLink.open("details.php", {
            height: height, width: width,
            overlayOpacity: 0.6, method: "POST",
            title: city,
            data: {"city": city, "country": country}
        });
        // Center that thing; the plugin has a slight offset (20px); hardcoded
        // adding another +40 to fix this.
        $(".sparkling-modal-frame").css("margin-left", Math.round((width + 40) / -2) + "px");
    });

    // Help page (the info page)
    $(document).on("click", "#page-info", function() {
        var width  = parseInt($(window).width()) - 200;
        var height = parseInt($(window).height()) - 200;
        $.modalLink.open("info.php", {
            height: height, width: width,
            overlayOpacity: 0.6
        });
        // Center that thing; the plugin has a slight offset (20px); hardcoded
        // adding another +40 to fix this.
        $(".sparkling-modal-frame").css("margin-left", Math.round((width + 40) / -2) + "px");
    });

    // Reload button to reset view
    $(document).on("click", "#page-reload", function() {
        location.reload("true");
    });

    // On document ready: Initialize globe
    $(document).ready(function() {

        /* Note that they rely on window.end_year and window.end_month! */
        $.fn.init_navigation_years();
        $.fn.init_navigation_months();
        $.fn.update_navigation_months();

        // Triggering adjustment of details panel
        $.fn.adjust_detail_panel_width();

        var product = $.fn.get_product();

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

        // Year navigation
        $("#year-bwd").on("click", function() {
             var cur = $('#years select option:selected')
             $(cur).prev().prop('selected', 'selected');
             $(cur).prop('selected', false)
             $("#years select").change() // Trigger change
        });
        $("#year-fwd").on("click", function() {
             var cur = $('#years select option:selected')
             $(cur).next().prop('selected', 'selected');
             $(cur).prop('selected', false)
             $("#years select").change() // Trigger change
        });


        /* Keypress features
         * Key:  39: right
         *       37: left
         *       38: up
         *       40: down
         * KeyL  49: '1'
         *       50: '2'
         *       51: '3'
         *       52: '4'
         */
        $(document).bind("keydown", function(e) {
            var nav_keys     = [39, 37, 38, 40];
            var product_keys = [49, 50, 51, 52];

            // Changing year/month
            if (nav_keys.indexOf(e.which) >= 0) {
                if (e.which == 38) {
                    // Previous 'months li'. Check if found and not disabled.
                    var tmp = $("ul#months > li.active").prev();
                    if (tmp.length > 0 && !tmp.hasClass("disabled")) { tmp.click(); }
                } else if (e.which == 40) {
                    // Previous 'months li'. Check if found and not disabled.
                    var tmp = $("ul#months > li.active").next();
                    if (tmp.length > 0 && !tmp.hasClass("disabled")) { tmp.click(); }
                } else if (e.which == 37) {
                    // Move to previous year if there is one
                    var tmp = $("#years > select > option:selected").prev();
                    if (tmp.length > 0) {
                        $(tmp).prop("selected", true);
                        $("#years > select").trigger("change");
                    }
                } else if (e.which == 39) {
                    // Move to next year if there is one
                    var tmp = $("#years > select > option:selected").next();
                    if (tmp.length > 0) {
                        $(tmp).prop("selected", true);
                        $("#years > select").trigger("change");
                    }
                }
            }

            // Changing products
            if (product_keys.indexOf(e.which) >= 0) {
                if (e.which == 49) {
                    $("ul#product > li[product='2t']").click();
                } else if (e.which == 50) {
                    $("ul#product > li[product='tp']").click();
                } else if (e.which == 51) {
                    $("ul#product > li[product='ci']").click();
                } else if (e.which == 52) {
                    $("ul#product > li[product='swvl1']").click();
                }
                event.preventDefault(); // Prevent default key functionality
            }
            //console.log(e.which)
        });

    });
})(jQuery);




