

(in-package :relays-ui)


(rx:defm three-fn ()
  `(progn
     (rx:js "import * as THREE from './three.module.js'")
     (rx:js "import { OrbitControls } from './OrbitControls.js'")
     (defvar *max_points* 50000)
     (defvar renderer (ps:new (ps:chain -t-h-r-e-e (-web-g-l-renderer))))
     (defvar scene (ps:new (ps:chain -t-h-r-e-e (-scene))))
     (defvar fov 45)
     (defvar aspect (/ (ps:@ window inner-width)
                       (ps:@ window inner-height)))
     (defvar near 1)
     (defvar far 1000)
     (defvar camera (ps:new (ps:chain
                             -t-h-r-e-e
                             (-perspective-camera fov aspect near far))))
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
  `(progn
     (defun on-change-near (v)
       ((ps:@ console log) v)
       (when (> (ps:abs (- near v)) 1)
         (setf (ps:@ camera near) v)
         ((ps:@ camera update-projection-matrix))))
     (defun on-change-far (v)
       ((ps:@ console log) v)
       (when (> (ps:abs (- far v)) 50)
         (setf (ps:@ camera far) v)
         ((ps:@ camera update-projection-matrix))))
     (defun -lines (props)
       (rx:div (rx:{} width (ps:@ window inner-width)
                      height (ps:@ window inner-height))
               (rx:div (rx:{} id "lines" key "lines"))
               (rx:react-element -range
                                 (rx:{} id "near"
                                        key "near"
                                        min 0
                                        max 100
                                        initial near
                                        on-change on-change-near))
               (rx:react-element -range
                                 (rx:{} id "far"
                                        key "far"
                                        min 0
                                        max 10000
                                        initial far
                                        on-change on-change-far))))))




