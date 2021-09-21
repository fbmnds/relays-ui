

(in-package :relays-ui)


(rx:defm three-fn ()
  `(progn
     (rx:js "import * as THREE from './three.module.js'")
     (rx:js "import { OrbitControls } from './OrbitControls.js'")
     (defvar *max_points* 50000)
     (defvar renderer (ps:new (ps:chain -t-h-r-e-e (-web-g-l-renderer))))
     (defvar scene (ps:new (ps:chain -t-h-r-e-e (-scene))))
     (defvar camera (ps:new (ps:chain
                             -t-h-r-e-e
                             (-perspective-camera
                              45
                              (/ (ps:@ window inner-width)
                                 (ps:@ window inner-height))
                              1 1000))))
     (defvar controls (ps:new (-orbit-controls
                               camera
                               (ps:@ renderer dom-element))))
     (defvar geometry (ps:new (ps:chain -t-h-r-e-e (-buffer-geometry))))
     (defvar positions (ps:new (-float32-array (* 3 *max_points*))))
     (defvar material (ps:new (ps:chain -t-h-r-e-e (-line-basic-material
                                                    (rx:{} color #xff0000
                                                           linewidth 2)))))
     (defvar line (ps:new (ps:chain -t-h-r-e-e (-line geometry material))))
     (defvar draw-count 2)
     (defun render ()
       (ps:chain renderer (render scene camera)))
     (defun on-window-resize ()
       (setf (ps:@ camera aspect) (/ (ps:@ window inner-width)
                                     (ps:@ window inner-height)))
       (ps:chain camera (update-projection-matrix))
       (ps:chain renderer (set-size (ps:@ window inner-width)
                                    (ps:@ window inner-height))))
     (defun update-positions ()
       (let ((pos (ps:@ line geometry attributes position array))
             x y z)
         (dotimes (i *max_points*)
           (if (= (ps:% i 2500) 0)
               (setf x 0 y 0 z 0)
               (setf x (+ x (* (- (ps:chain -math (random)) 0.5) 30))
                     y (+ y (* (- (ps:chain -math (random)) 0.5) 30))
                     z (+ z (* (- (ps:chain -math (random)) 0.5) 30))))
           (setf (ps:@ pos (* 3 i)) x)
           (setf (ps:@ pos (+ (* 3 i) 1)) y)
           (setf (ps:@ pos (+ (* 3 i) 2)) z))))
     (defun init ()
       (ps:chain renderer (set-pixel-ratio (ps:@ window device-pixel-ratio)))
       (ps:chain renderer (set-size (ps:@ window inner-width)
                                    (ps:@ window inner-height)))
       (ps:chain camera position (set 0 0 1000))
       (ps:chain controls (listen-to-key-events window))
       (setf (ps:@ controls min-distance) 100)
       (setf (ps:@ controls max-distance) 50000)
       (setf (ps:@ controls max-polar-angle) 1.6)
       (ps:chain geometry
                 (set-attribute "position"
                                (ps:new (ps:chain -t-h-r-e-e
                                                  (-buffer-attribute
                                                   positions 3)))))
       (ps:chain geometry (set-draw-range 0 draw-count))
       (ps:chain scene (add line))
       (ps:chain window (add-event-listener "resize" on-window-resize))
       (update-positions))
     (defun animate ()
       (request-animation-frame animate)
       (ps:chain controls (update))
       (setf draw-count (ps:% (+ 1 draw-count) *max_points*))
       (ps:chain line geometry (set-draw-range 0 draw-count))
       (when (= draw-count 0)
         ((ps:@ console log) "drawCount 0")
         (update-positions)
         (setf (ps:@ line geometry attributes position needs-update) true))
       (when (= 0 (ps:% (+ 1 draw-count) 500))
         (ps:chain line material color
                   (set-h-s-l (ps:chain -math (random)) 1 0.5)))
       (ps:chain renderer (render scene camera)))
     (init)
     (animate)))

(rx:defm lines-fn ()
  `(defun -lines (props)
       (rx:react-element :div
                         (rx:{} id "lines"
                                width (ps:@ window inner-width)
                                height (ps:@ window inner-height) ))))

(rx:defm lines-tab ()
  `(rx:react-bootstrap-tab* -tab
                            (rx:{} event-key "lines" title "Lines")
                            (rx:react-element -lines nil)))



