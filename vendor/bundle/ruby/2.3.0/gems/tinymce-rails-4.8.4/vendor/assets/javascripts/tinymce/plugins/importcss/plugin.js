!function(){"use strict";var e=tinymce.util.Tools.resolve("tinymce.PluginManager"),d=tinymce.util.Tools.resolve("tinymce.dom.DOMUtils"),v=tinymce.util.Tools.resolve("tinymce.EditorManager"),h=tinymce.util.Tools.resolve("tinymce.Env"),y=tinymce.util.Tools.resolve("tinymce.util.Tools"),o=function(e){return e.getParam("importcss_merge_classes")},n=function(e){return e.getParam("importcss_exclusive")},_=function(e){return e.getParam("importcss_selector_converter")},r=function(e){return e.getParam("importcss_selector_filter")},i=function(e){return e.getParam("importcss_groups")},u=function(e){return e.getParam("importcss_append")},l=function(e){return e.getParam("importcss_file_filter")},a=function(t){return"string"==typeof t?function(e){return-1!==e.indexOf(t)}:t instanceof RegExp?function(e){return t.test(e)}:t},f=function(f,e,m){var g=[],n={};function p(e,t){var n,r,i,c=e.href;if(r=c,i=h.cacheSuffix,"string"==typeof r&&(r=r.replace("?"+i,"").replace("&"+i,"")),(c=r)&&m(c,t)&&(o=c,u=(s=f).settings,!(l=!1!==u.skin&&(u.skin||"lightgray"))||o!==(u.skin_url?s.documentBaseURI.toAbsolute(u.skin_url):v.baseURL+"/skins/"+l)+"/content"+(s.inline?".inline":"")+".min.css")){var s,o,u,l;y.each(e.imports,function(e){p(e,!0)});try{n=e.cssRules||e.rules}catch(a){}y.each(n,function(e){e.styleSheet?p(e.styleSheet,!0):e.selectorText&&y.each(e.selectorText.split(","),function(e){g.push(y.trim(e))})})}}y.each(f.contentCSS,function(e){n[e]=!0}),m||(m=function(e,t){return t||n[e]});try{y.each(e.styleSheets,function(e){p(e)})}catch(t){}return g},x=function(e,t){var n,r=/^(?:([a-z0-9\-_]+))?(\.[a-z0-9_\-\.]+)$/i.exec(t);if(r){var i=r[1],c=r[2].substr(1).split(".").join(" "),s=y.makeMap("a,img");return r[1]?(n={title:t},e.schema.getTextBlockElements()[i]?n.block=i:e.schema.getBlockElements()[i]||s[i.toLowerCase()]?n.selector=i:n.inline=i):r[2]&&(n={inline:"span",title:t.substr(1),classes:c}),!1!==o(e)?n.classes=c:n.attributes={"class":c},n}},T=function(e,t){return null===t||!1!==n(e)},c=x,t=function(h){h.on("renderFormatsMenu",function(e){var t,p={},c=a(r(h)),v=e.control,s=(t=i(h),y.map(t,function(e){return y.extend({},e,{original:e,selectors:{},filter:a(e.filter),item:{text:e.title,menu:[]}})})),o=function(e,t){if(f=e,g=p,!(T(h,m=t)?f in g:f in m.selectors)){u=e,a=p,T(h,l=t)?a[u]=!0:l.selectors[u]=!0;var n=(c=(i=h).plugins.importcss,s=e,((o=t)&&o.selector_converter?o.selector_converter:_(i)?_(i):function(){return x(i,s)}).call(c,s,o));if(n){var r=n.name||d.DOM.uniqueId();return h.formatter.register(r,n),y.extend({},v.settings.itemDefaults,{text:n.title,format:r})}}var i,c,s,o,u,l,a,f,m,g;return null};u(h)||v.items().remove(),y.each(f(h,e.doc||h.getDoc(),a(l(h))),function(n){if(-1===n.indexOf(".mce-")&&(!c||c(n))){var e=(r=s,i=n,y.grep(r,function(e){return!e.filter||e.filter(i)}));if(0<e.length)y.each(e,function(e){var t=o(n,e);t&&e.item.menu.push(t)});else{var t=o(n,null);t&&v.add(t)}}var r,i}),y.each(s,function(e){0<e.item.menu.length&&v.add(e.item)}),e.control.renderNew()})},s=function(t){return{convertSelectorToFormat:function(e){return c(t,e)}}};e.add("importcss",function(e){return t(e),s(e)})}();