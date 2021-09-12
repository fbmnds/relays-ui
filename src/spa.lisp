
(in-package #:relays-ui)


(defparameter *app-js*
  (ps:ps* `(progn
             (alert-fn)
             (toggle-switch-fn)
             (relay-switch-fn 1)
             (relay-switch-fn 2)
             (relay-switch-fn 3)
             (relay-switch-fn 4)
             (relay-url-fn)
             (relays-fn)
             (render-relays))))

(defparameter *index*
  (sp:with-html-string
    (:doctype)
    (:html
     (:head
      (:title "Hello React")
      (:link :rel "stylesheet" :href "/css/bootstrap.css")
      (:link :rel "stylesheet" :href "/css/toggle-switch.css")
      (:link :rel "icon" :href "/assets/favicon.ico")
      (:script :type "application/javascript" :src "/js/bootstrap-bundle.js")
      (:script :type "application/javascript" :src "/js/react.js")
      (:script :type "application/javascript" :src "/js/react-dom.js")
      (:script :type "application/javascript" :src "/js/react-bootstrap.js"))
     (:body
      (:div :id "relays" :class "relays")
      (:script :type "application/javascript" :src "/js/App.js")))))

(defun route (env path rc hdr body &optional ends-with)
  (o:match env
      ((o:guard (o:property :path-info path-info)
                (if ends-with
                    (a:ends-with-subseq path path-info)
                    (a:starts-with-subseq path path-info)))
       (if (pathnamep body)
           `(,rc ,hdr ,body)
           `(,rc ,hdr (,body))))))

(defun handler (env)
  (let ((js-hdr '(:content-type "application/javascript")))
    (handler-case
        (or
         (route env "/index.html" 200 nil *index*)
         (route env "/js/react.js" 200 js-hdr *react*)
         (route env "/js/react-dom.js" 200 js-hdr *react-dom*)
         (route env "/js/react-bootstrap.js" 200 js-hdr *react-bootstrap*)
         (route env "/js/App.js" 200 js-hdr *app-js*)
         (route env "/css/toggle-switch.css" 200 nil *toggle-switch-css* t)
         (route env "/css/bootstrap.css" 200 nil *bootstrap-css* t)
         (route env "/js/bootstrap-bundle.js" 200 js-hdr *bootstrap-bundle-js*)
         (route env "/assets/favicon.ico"
                200 '(:content-type "image/x-icon") *favicon* t)
         `(404 nil (,(format nil "Path not found~%"))))
      (t (e) (if *debug*
                 `(500 nil (,(format nil "Internal Server Error~%~A~%" e)))
                 `(500 nil (,(format nil "Internal Server Error"))))))))

