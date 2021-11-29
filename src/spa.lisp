
(in-package #:relays-ui)


(defparameter *app-js*
  (ps:ps*
   `(progn
      (ps:defvar *__ps_mv_reg*)
      (alert-fn)
      (rx:toggle-switch-fn)
      (relay-switch-fn "-relays-16-e5-f0" 1)
      (relay-switch-fn "-relays-16-e5-f0" 2)
      (relay-switch-fn "-relays-16-e5-f0" 3)
      (relay-switch-fn "-relays-16-e5-f0" 4)
      (relay-switch-fn "-relays-4-d-c-c5-f" 1)
      (relay-switch-fn "-relays-4-d-c-c5-f" 2)
      (relay-switch-fn "-relays-4-d-c-c5-f" 3)
      (relay-switch-fn "-relays-4-d-c-c5-f" 4)
      (relay-url-fn)
      (relays-fn -relays-16-e5-f0
                 "http://192.168.178.37"
                 "ESP-16E5F0"
                 "ts_16e5f0")
      (relays-fn -relays-4-d-c-c5-f
                 "http://192.168.178.63"
                 "ESP-4DCC5F"
                 "ts_4dcc5f")
      (lines-fn)
      (rx:range-fn)
      (three-fn)
      (tabs "-relays-16-e5-f0" "relays-tab" "mb-3" "relays")
      (let ((dom-element (rx:doc-element "lines")))
        (ps:chain renderer (set-size (ps:@ window inner-width)
                                     (* 0.75 (ps:@ window inner-height))))
        ((ps:@ dom-element append-child)
         (ps:chain renderer dom-element))))))

(defparameter *index*
  (sp:with-html-string
    (:doctype)
    (:html
     (:head
      (:title "Hello React")
      (:link :rel "stylesheet" :href "/css/bootstrap.css")
      (:link :rel "stylesheet" :href "/css/slider.css")
      (:link :rel "stylesheet" :href "/css/toggle-switch.css")
      (:link :rel "icon" :href "/assets/favicon.ico")
      (:script :type "application/javascript" :src "/js/bootstrap-bundle.js")
      (:script :type "application/javascript" :src "/js/react.js")
      (:script :type "application/javascript" :src "/js/react-dom.js")
      (:script :type "application/javascript" :src "/js/react-bootstrap.js")
      (:script :type "application/javascript" :src "/js/three.js")
      (:script :type "application/javascript" :src "/js/OrbitControls.js"))
     (:body
      (:div :id "relays")
      (:script :type "module" :src "/js/App.js")))))

(defparameter *boot*
  (sp:with-html-string
    (:doctype)
    (:html
     (:head
      (:meta :http-equiv "Cache-Control" :content "no-cache, no-store, must-revalidate")
      (:meta :http-equiv "Pragma" :content "no-cache")
      (:meta :http-equiv "Expires" :content "0")
      ;;(:meta :charset "utf-8")
      (:meta :name "viewport" :content "width=device-width, initial-scale=1")

      (:script :type "text/javascript" :src "/js/jquery.min.js")
      (:script "var clog_debug = true;")
      (:script :type "text/javascript" :src "/js/boot.js")
      
      (:link :rel "stylesheet" :href "/css/bootstrap.css")
      (:link :rel "stylesheet" :href "/css/slider.css")
      (:link :rel "stylesheet" :href "/css/toggle-switch.css")
      (:link :rel "icon" :href "/assets/favicon.ico")

      (:script :type "application/javascript" :src "/js/bootstrap-bundle.js")
      (:script :type "application/javascript" :src "/js/react.js")
      (:script :type "application/javascript" :src "/js/react-dom.js")
      (:script :type "application/javascript" :src "/js/react-bootstrap.js")
      (:script :type "application/javascript" :src "/js/three.js")
      (:script :type "application/javascript" :src "/js/OrbitControls.js"))
     (:body "Javascript must be enabled."))))

(defparameter *body*
  (sp:with-html-string
    (:body
      (:div :id "relays")
      (:script :type "module" :src "/js/App.js"))))

(defun handler (env)
  (let ((js-hdr '(:content-type "application/javascript"))
        (path (getf env :path-info)))
    (handler-case
        (or
         (rx:route path "/index.html"
                   200 '(:access-control-allow-origin "*") *index*)
         (rx:route path "/js/react.js" 200 js-hdr *react*)
         (rx:route path "/js/react-dom.js" 200 js-hdr *react-dom*)
         (rx:route path "/js/react-bootstrap.js" 200 js-hdr *react-bootstrap*)
         (rx:route path "/js/three.js" 200 js-hdr *three*)
         ;;(rx:route path "/js/three.module.js" 200 js-hdr *three-module*)
         ;;(rx:route path "/build/three.module.js" 200 js-hdr *three-module*)
         (rx:route path "/js/OrbitControls.js" 200 js-hdr *orbit-controls*)
         (rx:route path "/js/App.js" 200 js-hdr *app-js*)
         (rx:route path "/css/toggle-switch.css" 200 nil *toggle-switch-css* t)
         (rx:route path "/css/slider.css" 200 nil *slider-css* t)
         (rx:route path "/css/bootstrap.css" 200 nil *bootstrap-css* t)
         (rx:route path "/js/bootstrap-bundle.js" 200 js-hdr *bootstrap-bundle-js*)
         #-ecl
         (rx:route path "/assets/favicon.ico"
                   200 '(:content-type "image/x-icon") *favicon* t)
         (rx:route path "/assets/data.csv"
                   200 '(:content-type "plain/text") *data* t)
         `(404 nil (,(format nil "Path not found~%"))))
      (t (e) (if *debug*
                 `(500 nil (,(format nil "Internal Server Error~%~A~%" e)))
                 `(500 nil (,(format nil "Internal Server Error"))))))))

(defun export-spa (path &rest args)
  (let ((path (if (eq #\/ (elt path (1- (length path))))
                  path
                  (concatenate 'string path "/"))))
    (uiop:delete-directory-tree (make-pathname :directory path)
                              :validate (y-or-n-p "delete '~a'?(y/n) " path)
                              :if-does-not-exist :ignore)
  (ensure-directories-exist (concatenate 'string path "js/"))
  (ensure-directories-exist (concatenate 'string path "css/"))
  (ensure-directories-exist (concatenate 'string path "assets/"))
  (flet ((write-spa (file content)
           (a:write-string-into-file content (concatenate 'string path file)
                                     :if-exists :supersede
                                     :if-does-not-exist :create)))
    (if (member :clog args)
        (progn
          (write-spa "boot.html" *boot*)
          (uiop:copy-file (merge-pathnames #p"boot.js" *clog-js*)
                          (concatenate 'string path "js/boot.js"))
          (uiop:copy-file (merge-pathnames #p"jquery-ui.js" *clog-js*)
                          (concatenate 'string path "js/jquery-ui.js"))
          (uiop:copy-file (merge-pathnames #p"jquery.min.js" *clog-js*)
                          (concatenate 'string path "js/jquery.min.js"))
          (uiop:copy-file (merge-pathnames #p"jquery-ui.css" *clog-css*)
                          (concatenate 'string path "css/jquery-ui.css")))
        (write-spa "index.html" *index*))
    (write-spa "js/react.js" *react*)
    (write-spa "js/react-dom.js" *react-dom*)
    (write-spa "js/react-bootstrap.js" *react-bootstrap*)
    (write-spa "js/three.js" *three*)
    (write-spa "js/OrbitControls.js" *orbit-controls*)
    (write-spa "js/App.js" *app-js*)
    (write-spa "css/toggle-switch.css" *toggle-switch-css*)
    (write-spa "css/slider.css" *slider-css*)
    (write-spa "css/bootstrap.css" *bootstrap-css*)
    (write-spa "js/bootstrap-bundle.js" *bootstrap-bundle-js*)
    (uiop:copy-file *favicon* (concatenate 'string path "assets/favicon.ico"))
    (uiop:copy-file *data* (concatenate 'string path "assets/data.csv")))))




