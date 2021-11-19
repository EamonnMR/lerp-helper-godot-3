# lerp-helper-godot-3
Class to make lerp based networking less copypasta intensive

See:
https://www.youtube.com/watch?v=w2p0ugw3afs
and:
https://www.youtube.com/watch?v=XGyrKmOxLcc

The gist of this class is that you'll be sending server state freeze-frames to your clients. It expects you to implement the following methods on a Client singleton (I might include this later):

Client.time: current time according to the client. This should be some time in the past to account for latency.
Client.get_net_frame_current(id): returns the net frame data of the most recent frame for this entity or nothing if no such data is available
Client.get_net_frame_last(id): ditto, but for one frame in the past.

What's neat about this class is that it wraps the decision to interpolate or extrapolate and you can use it to directly update the values of the class you're using it on to the correct interpolated/extrapolated values like this:

```
func _physics_process(delta):
	if is_network_master():
		# Do server authoritative stuff
	else:
		var lerp_helper = LerpHelper.new(self, self.name)
		if lerp_helper.can_lerp:
			lerp_helper.lerp_member("member_name")
      # ... etc
		elif lerp_helper.can_extrapolate:
			lerp_helper.extrapolate_member("other_member")
      # ... etc
```
Which is nice.
