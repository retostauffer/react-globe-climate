
// Make 'earth' global
//earth = false;
//layer = false;

window.earth = false;
window.layer = false;

(function($){

    $.fn.get_product = function() {
        var prod = $("ul#product li.active").attr("product")
        if (prod === undefined) {
            var tmp = $("ul#product li:first-child")
            prod = $(tmp).attr("product")
            $(tmp).addClass("active")
        }
        var ymon = $("ul#yearmon li.active").attr("val")
        if (ymon === undefined) {
            var tmp = $("ul#yearmon li:first-child")
            ymon = $(tmp).attr("val")
            $(tmp).addClass("active")
        }
        return(prod + "/" + ymon)
    }

    $.fn.initialize_globe = function(product, position, zoom) {
        if (window.earth === false) {
            window.earth = new WE.map('earth_div');
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

    // On document ready: Initialize globe
    $(document).ready(function() {

        var product = $.fn.get_product()

        console.log(product)
        earth = $.fn.initialize_globe(product, position = [47.5, 11.3], zoom = 2)
        console.log("Current zoom:" + earth.getZoom())

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
