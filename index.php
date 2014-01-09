<html>
    <head>
        <meta name="viewport" content="width=device-width,user-scalable=no" />
        <link rel="stylesheet" type="text/css" href="main.css" />
        <script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>
        <script src="main.js">
        </script>
        <script>
        CanvasRenderingContext2D.prototype.clear = 
            CanvasRenderingContext2D.prototype.clear || function (preserveTransform) {
                if (preserveTransform) {
                    this.save();
                    this.setTransform(1, 0, 0, 1, 0, 0);
                }

                this.clearRect(0, 0, this.canvas.width, this.canvas.height);

                if (preserveTransform) {
                    this.restore();
                }        
            };
        jQuery.event.special.dblclick = {
            setup: function(data, namespaces) {
                var elem = this,
                $elem = jQuery(elem);
             $elem.bind('touchend.dblclick', jQuery.event.special.dblclick.handler);
            },

            teardown: function(namespaces) {
                var elem = this,
                    $elem = jQuery(elem);
                $elem.unbind('touchend.dblclick');
            },

            handler: function(event) {
                var elem = event.target,
                    $elem = jQuery(elem),
                    lastTouch = $elem.data('lastTouch') || 0,
                    now = new Date().getTime();

                var delta = now - lastTouch;
                if(delta > 20 && delta<200){
                    $elem.data('lastTouch', 0);
                    $elem.trigger('dblclick');
                }else
                    $elem.data('lastTouch', now);
            }
        };
    </script>
    </head>
    <body>
        <div class="wrapper">
            <canvas id="draw" width="320" height="399">
            </canvas>
            <canvas id="view" width="320" height="399">
            </canvas>
            <div class="main">
            </div>
        </div>
        <div class="control">
            <div class="source">
                <div class="circle-start circle"> </div>
            </div>
            <input type="range" class="slider" value="0" min="0" max="100"> </input>
            <input type="text" class="slider-number" value="0.0"> </input>
        </div>
    </body>
</html>
