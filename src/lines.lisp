
(in-package :relays-ui)


(rx:defm three-fn ()
  `(progn
     (rx:js "import * as THREE from './three.module.js'")
     (rx:js "import { OrbitControls } from './OrbitControls.js'")
     (defvar *max_points* 50000)
     (defvar *data_points* 5000)
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
     (defvar *ac* (rx:{} from-idx 0
                         to-idx 2
                         upper-idx *data_points*
                         tick-update t
                         data-update ps:false
                         mode :random-init
                         timestamp (ps:chain -date (now))
                         repeat t))
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
         (dotimes (i *data_points*)
           (if (= (ps:rem i 2500) 0)
               (setf x 0 y 0 z 0)
               (setf x (+ x (* (- (ps:chain -math (random)) 0.5) 30))
                     y (+ y (* (- (ps:chain -math (random)) 0.5) 30))
                     z (+ z (* (- (ps:chain -math (random)) 0.5) 30))))
           (setf (ps:@ pos (* 3 i)) x)
           (setf (ps:@ pos (+ (* 3 i) 1)) y)
           (setf (ps:@ pos (+ (* 3 i) 2)) z)))
       (setf (ps:@ *ac* upper-idx) *data_points*)
       (setf (ps:@ *ac* data-update) t))
     (defun update-positions-from (data)
       (let ((pos (ps:@ line geometry attributes position array)))
         (dotimes (i (ps:@ data length))
           (destructuring-bind (x y z) (ps:aref data i)
             (setf (ps:@ pos (* 3 i)) (parse-float x))
             (setf (ps:@ pos (+ (* 3 i) 1)) (parse-float y))
             (setf (ps:@ pos (+ (* 3 i) 2)) (parse-float z)))))
       (setf (ps:@ *ac* upper-idx) (ps:@ data length))
       (setf (ps:@ *ac* data-update) t))
     (rx:js (format nil "
function updateData () {
    try {
        fetch('~a')
        .then(res => res.text())
        .then(res => { var r = res.split('\\n'); 
                       DATA_POINTS = r.length;  // not safe
                       return r; })
        .then(res => res.map(line => line.split(';')))
        .then(res => updatePositionsFrom(res))
    } catch (e) {
        console.log('error updateData ' + e.toString());
        updatePositions();
        return null;
    }
}" "http://localhost:5000/assets/data.csv"))
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
       (update-positions)
       nil)
     (defun tick ()
       (cond ((eql (ps:@ *ac* mode) :random-init)
              (setf (ps:@ *ac* tick-update) t)
              (setf (ps:@ *ac* from-idx) 0)
              (setf (ps:@ *ac* to-idx) 2)
              (setf (ps:@ *ac* data-update) t)
              (setf (ps:@ *ac* repeat) t)
              (setf (ps:@ *ac* upper-idx) *data_points*)
              (update-positions)
              (setf (ps:@ *ac* mode) :random))
             ((eql (ps:@ *ac* mode) :random)
              (setf (ps:@ *ac* to-idx) (1+ (ps:@ *ac* to-idx)))
              (when (and (ps:@ *ac* repeat)
                         (=  (ps:@ *ac* to-idx) (ps:@ *ac* uper-idx)))
                (update-positions)
                (setf (ps:@ *ac* data-update) t)
                (setf (ps:@ *ac* to-idx) 2))
              (ps:chain line geometry (set-draw-range (ps:@ *ac* from-idx)
                                                      (ps:@ *ac* to-idx))))
             ((eql (ps:@ *ac* mode) :csv-init)
              (setf (ps:@ *ac* timestamp) (ps:chain -date (now)))
              (setf (ps:@ *ac* from-idx) 0)
              (setf (ps:@ *ac* to-idx) 2)
              (setf (ps:@ *ac* repeat) ps:false)
              (update-data)
              (ps:chain line geometry (set-draw-range (ps:@ *ac* from-idx)
                                                          (ps:@ *ac* to-idx)))
              (setf (ps:@ *ac* mode) :csv-tock))
             ((eql (ps:@ *ac* mode) :csv-tick)
              (when (> (ps:chain -date (now)) (ps:@ *ac* timestamp))
                (setf (ps:@ *ac* to-idx) (1+ (ps:@ *ac* to-idx)))
                (when (= (ps:@ *ac* to-idx) (ps:@ *ac* upper-idx))
                  (if (ps:@ *ac* repeat)
                      (setf (ps:@ *ac* to-idx) 2)
                      (setf (ps:@ *ac* mode) :csv-pause)))
                (when (eql (ps:@ *ac* mode) :csv-tick)
                  (setf (ps:@ *ac* tick-update) t)
                  (ps:chain line geometry (set-draw-range (ps:@ *ac* from-idx)
                                                          (ps:@ *ac* to-idx)))
                  (setf (ps:@ *ac* mode) :csv-tock))))
             ((eql (ps:@ *ac* mode) :csv-tock)
              (setf (ps:@ *ac* timestamp) (+ (ps:chain -date (now)) 500))
              (setf (ps:@ *ac* tick-update) ps:false)
              (setf (ps:@ *ac* mode) :csv-tick))
             (t nil)))
     (defun animate ()
       (request-animation-frame animate)
       (ps:chain controls (update))
       (tick)
       (when (ps:@ *ac* tick-update)
         (when (ps:@ *ac* data-update)
           (setf (ps:@ line geometry attributes position needs-update) t)
           (setf (ps:@ *ac* data-update) ps:false))
         (when (= 0 (ps:rem (ps:@ *ac* to-idx) 500))
           (ps:chain line material color
                     (set-h-s-l (ps:chain -math (random)) 1 0.5))))
       (ps:chain renderer (render scene camera)))
     (init)
     (animate)))

(rx:defm lines-fn ()
  `(progn
     (defun on-change-near (v)
       (when (> (ps:abs (- near v)) 1)
         (setf (ps:@ camera near) v)
         ((ps:@ camera update-projection-matrix))))
     (defun on-change-far (v)
       ;;((ps:@ console log) v)
       (when (> (ps:abs (- far v)) 50)
         (setf (ps:@ camera far) v)
         ((ps:@ camera update-projection-matrix))))
     (defun on-change-random ()
       (setf (ps:@ *ac* mode) :random-init))
     (defun on-change-csv ()
       (setf (ps:@ *ac* mode) :csv-init))
     (defun -lines (props)
       (rx:use-state "upper" 1000)
       (defun on-change-to-idx (v)
         (setf (ps:@ *ac* to-idx) v)
         (set-upper (ps:@ *ac* upper-idx)))
       (rx:div (rx:{} width (ps:@ window inner-width)
                      height (ps:@ window inner-height))
               (rx:button (rx:{} id "csv-data-btn"
                                 key "csv-data"
                                 class-name "btn btn-primary btn-lg"
                                 on-click on-change-csv)
                          "Load CSV data")
               (rx:button (rx:{} id "random-data-btn"
                                 key "random-data"
                                 class-name "btn btn-primary btn-lg"
                                 on-click on-change-random)
                          "Random data")
               (rx:div (rx:{} id "lines" key "lines"))
               (rx:react-element -range
                                 (rx:{} id "to-idx"
                                        key "to-idx"
                                        min 2
                                        max upper
                                        initial 2
                                        on-change on-change-to-idx))
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


