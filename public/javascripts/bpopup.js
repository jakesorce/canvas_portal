/********************************************************************************* * @name: bPopup * @author: (c)Bjoern Klinggaard (http://dinbror.dk/bpopup - twitter@bklinggaard) * @version: 0.7.0.min *********************************************************************************/(function (b) {
    b.fn.bPopup = function (n, p) {
        function t() {
            b.isFunction(a.onOpen) && a.onOpen.call(c);
            k = (e.data("bPopup") || 0) + 1;
            d = "__bPopup" + k;
            l = "auto" !== a.position[1];
            m = "auto" !== a.position[0];
            i = "fixed" === a.positionStyle;
            j = r(c, a.amsl);
            f = l ? a.position[1] : j[1];
            g = m ? a.position[0] : j[0];
            q = s();
            a.modal && b('<div class="bModal ' + d + '"></div>').css({"background-color":a.modalColor, height:"100%", left:0, opacity:0, position:"fixed", top:0, width:"100%", "z-index":a.zIndex + k}).each(function () {
                a.appending && b(this).appendTo(a.appendTo)
            }).animate({opacity:a.opacity}, a.fadeSpeed);
            c.data("bPopup", a).data("id", d).css({left:!a.follow[0] && m || i ? g : h.scrollLeft() + g, position:a.positionStyle || "absolute", top:!a.follow[1] && l || i ? f : h.scrollTop() + f, "z-index":a.zIndex + k + 1}).each(function () {
                a.appending && b(this).appendTo(a.appendTo);
                if (null != a.loadUrl)switch (a.contentContainer = b(a.contentContainer || c), a.content) {
                    case "iframe":
                        b('<iframe scrolling="no" frameborder="0"></iframe>').attr("src", a.loadUrl).appendTo(a.contentContainer);
                        break;
                    default:
                        a.contentContainer.load(a.loadUrl)
                }
            }).fadeIn(a.fadeSpeed, function () {
                b.isFunction(p) && p.call(c);
                u()
            })
        }

        function o() {
            a.modal && b(".bModal." + c.data("id")).fadeOut(a.fadeSpeed, function () {
                b(this).remove()
            });
            c.stop().fadeOut(a.fadeSpeed, function () {
                null != a.loadUrl && a.contentContainer.empty()
            });
            e.data("bPopup", 0 < e.data("bPopup") - 1 ? e.data("bPopup") - 1 : null);
            a.scrollBar || b("html").css("overflow", "auto");
            b("." + a.closeClass).die("click." + d);
            b(".bModal." + d).die("click");
            h.unbind("keydown." + d);
            e.unbind("." + d);
            c.data("bPopup", null);
            b.isFunction(a.onClose) && setTimeout(function () {
                a.onClose.call(c)
            }, a.fadeSpeed);
            return!1
        }

        function u() {
            e.data("bPopup", k);
            b("." + a.closeClass).live("click." + d, o);
            a.modalClose && b(".bModal." + d).live("click", o).css("cursor", "pointer");
            (a.follow[0] || a.follow[1]) && e.bind("scroll." + d,function () {
                q && c.stop().animate({left:a.follow[0] && !i ? h.scrollLeft() + g : g, top:a.follow[1] && !i ? h.scrollTop() + f : f}, a.followSpeed)
            }).bind("resize." + d, function () {
                if (q = s())j = r(c, a.amsl), a.follow[0] && (g = m ? g : j[0]), a.follow[1] && (f = l ? f : j[1]), c.stop().each(function () {
                    i ? b(this).css({left:g, top:f}, a.followSpeed) : b(this).animate({left:m ? g : g + h.scrollLeft(), top:l ? f : f + h.scrollTop()}, a.followSpeed)
                })
            });
            a.escClose && h.bind("keydown." + d, function (a) {
                27 == a.which && o()
            })
        }

        function r(a, b) {
            var c = (e.width() - a.outerWidth(!0)) / 2, d = (e.height() - a.outerHeight(!0)) / 2 - b;
            return[c, 20 > d ? 20 : d]
        }

        function s() {
            return e.height() > c.outerHeight(!0) + 20 && e.width() > c.outerWidth(!0) + 20
        }

        b.isFunction(n) && (p = n, n = null);
        var a = b.extend({}, b.fn.bPopup.defaults, n);
        a.scrollBar || b("html").css("overflow", "hidden");
        var c = this, h = b(document), e = b(window), k, d, q, l, m, i, j, f, g;
        this.close = function () {
            a = c.data("bPopup");
            o()
        };
        return this.each(function () {
            c.data("bPopup") || t()
        })
    };
    b.fn.bPopup.defaults = {amsl:50, appending:!0, appendTo:"body", closeClass:"bClose", content:"ajax", contentContainer:null, escClose:!0, fadeSpeed:250, follow:[!0, !0], followSpeed:500, loadUrl:null, modal:!0, modalClose:!0, modalColor:"#000", onClose:null, onOpen:null, opacity:0.7, position:["auto", "auto"], positionStyle:"absolute", scrollBar:!0, zIndex:9997}
})(jQuery);


