/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.3
 *
 * Copyright (c) 2013-2015, Esoteric Software
 * All rights reserved.
 *
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to use, install, execute and perform the Spine
 * Runtimes Software (the "Software") and derivative works solely for personal
 * or internal use. Without the written permission of Esoteric Software (see
 * Section 2 of the Spine Software License Agreement), you may not (a) modify,
 * translate, adapt or otherwise create derivative works, improvements of the
 * Software or develop new applications using the Software or (b) remove,
 * delete, alter or obscure any trademarks or any copyright, trademark, patent
 * or other intellectual property or proprietary rights notices on or in the
 * Software, including any copy thereof. Redistributions in binary or source
 * form must include this license and terms.
 *
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

package spine.animation;

import spine.Event;
import spine.Skeleton;

class EventTimeline implements Timeline
{
    public var frameCount(get, never) : Int;

    public var frames : Array<Float>;  // time, ...
    public var events : Array<Event>;

    public function new(frameCount : Int)
    {
        frames = new Array<Float>();
        events = new Array<Event>();
        for (i in 0...frameCount) {
            frames.push(0);
            events.push(null);
        }
    }

    private function get_frameCount() : Int
    {
        return frames.length;
    }

    /** Sets the time and value of the specified keyframe. */
    public function setFrame(frameIndex : Int, event : Event) : Void
    {
        frames[frameIndex] = event.time;
        events[frameIndex] = event;
    }

    /** Fires events for frames > lastTime and <= time. */
    public function apply(skeleton : Skeleton, lastTime : Float, time : Float, firedEvents : Array<Event>, alpha : Float) : Void
    {
        if (firedEvents == null)
        {
            return;
        }

        if (lastTime > time)
        {
            // Fire events after last time for looped animations.
            apply(skeleton, lastTime, spine.compat.Compat.INT_MAX, firedEvents, alpha);
            lastTime = -1;
        }
        else
        {
            if (lastTime >= frames[frameCount - 1])
            {
                // Last time is after last frame.
                return;
            }
        }
        if (time < frames[0])
        {
            return;
        }  // Time is before first frame.

        var frame : Int;
        if (lastTime < frames[0])
        {
            frame = 0;
        }
        else
        {
            frame = Animation.binarySearch1(frames, lastTime);
            var frameTime : Float = frames[frame];
            while (frame > 0)
            {
                // Fire multiple events with the same frame.
                if (frames[frame - 1] != frameTime)
                {
                    break;
                }
                frame--;
            }
        }
                while (frame < frameCount && time >= frames[frame])
        {
            firedEvents[firedEvents.length] = events[frame];
            frame++;
        }
    }
}
