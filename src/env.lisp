
(in-package #:relays-ui)

(defparameter *debug* t)

(defparameter *relay-url* '("http://ESP-16E5F0" "http://ESP-4DCC5F"))

(defparameter *paths* (make-hash-table))

(setf (gethash :home *paths*) (user-homedir-pathname))
(setf (gethash :projects *paths*)
      (merge-pathnames #p"projects/" (gethash :home *paths*)))
(setf (gethash :css *paths*)
      (merge-pathnames #p"relays-ui/css/" (gethash :projects *paths*)))
(setf (gethash :reactjs *paths*)
      (merge-pathnames #p"js-libs/react/" (gethash :projects *paths*)))
(setf (gethash :bootstrap *paths*)
      (merge-pathnames #p"js-libs/bootstrap-build/"
                       (gethash :projects *paths*)))
(setf (gethash :assets *paths*)
      (merge-pathnames #p"js-libs/assets/"
                       (gethash :projects *paths*)))
(setf (gethash :three *paths*)
      (merge-pathnames #p"js-libs/three.0.127.0/build/"
                       (gethash :projects *paths*)))
(setf (gethash :three-examples *paths*)
      (merge-pathnames #p"js-libs/three.0.127.0/examples/"
                       (gethash :projects *paths*)))

(defparameter *react*
  (uiop:read-file-string (merge-pathnames #p"react.17.0.2.js"
                                          (gethash :reactjs *paths*))))

(defparameter *react-dom*
  (uiop:read-file-string (merge-pathnames #p"react-dom.17.0.2.js"
                                          (gethash :reactjs *paths*))))


(defparameter *base-css* nil)

(defparameter *toggle-switch-css*
  (uiop:read-file-string (merge-pathnames #p"toggle-switch.css"
                                          (gethash :css *paths*))))

(defparameter *slider-css*
  (uiop:read-file-string (merge-pathnames #p"slider.css"
                                          (gethash :css *paths*))))

(defparameter *bootstrap-css*
  (uiop:read-file-string (merge-pathnames #p"bootstrap-5.0.2.min.css"
                                          (gethash :bootstrap *paths*))))

(defparameter *bootstrap-bundle-js*
  (uiop:read-file-string (merge-pathnames #p"bootstrap-5.0.2.bundle.min.js"
                                          (gethash :bootstrap *paths*))))

(defparameter *react-bootstrap*
  (uiop:read-file-string (merge-pathnames #p"react-bootstrap.min.js"
                                          (gethash :bootstrap *paths*))))

(defparameter *three*
  (uiop:read-file-string (merge-pathnames #p"three.min.js"
                                          (gethash :three *paths*))))

(defparameter *three-module*
  (uiop:read-file-string (merge-pathnames #p"three.module.js"
                                          (gethash :three *paths*))))

(defparameter *orbit-controls*
  (uiop:read-file-string (merge-pathnames #p"jsm/controls/OrbitControls.js"
                                          (gethash :three-examples *paths*))))

(defparameter *favicon* (merge-pathnames #p"favicon.ico"
                                         (gethash :assets *paths*)))

(defparameter *clack-server* nil)

(defun clack-start (handler)
  (setf *clack-server*
        (clack:clackup handler
                       :server :woo
                       :address "0.0.0.0")))

(defun clack-stop ()
  (prog1
   (clack:stop *clack-server*)
   (setf *clack-server* nil)))

(defun clack-restart (handler)
  (clack-stop)
  (clack-start handler))

