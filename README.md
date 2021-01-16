# tightbeam
com-sat com-bat
FROM ADAM SMITH:

TIGHTBEAM

TIGHTBEAM is a competitive, two-player game, intended for play in short sessions (perhaps 2 minutes each). It has a hard science fiction setting, and gameplay focuses on balancing hybrid dynamical systems. The game should have elements of shooters, but completely non-spatial, and elements of the mixed micro- and macro- attention scales of real-time strategy games.

Narrative Premise

Some time into the future, millions of tiny satellites or “nodes” have been placed into orbit around the Earth to form nodes in various high-bandwidth laser communications networks. The networks deployed by different metanational brands were operated in a cooperative mode for a time. However, as deployed capacity began to saturate demand from the decreasing human population, competitive tensions gave way to overt sabotage. The nodes are so small that they are effectively impossible to be found by observers who don’t already know where to look, except by very rare chance. When one brand learns the orbital ephemerides for a node of another brand, it has a strong incentive to eliminate that node. A directed-energy attack of one node on another tends to reveal enough information about the location of the attacking node that counterattacks are immediately possible.

The nodes, originally intended for only communication purposes, have five major components:

Microfusion furnace: The furnace is capable of producing immense amounts of power relative to the size of the satellite, however all power that is not put into useful work must be quickly radiated into space to avoid catastrophic overheating of the node. The output of the furnace can be dialed up or down, but the mechanism is slow to respond to commands relative to the timescales of other activity on the node.

Tunable laser emitter: The emitter was originally designed to convey large information packages from one node to another in a very short time. As a result, it has a very high transmit power rating. An excess of incoming laser messages can overheat a node. The wavelength of the emitted laser can be precisely tuned over a certain range of wavelengths.

Chargeable capacitors: Even the full power of the microfusion furnace cannot solely sustain the power requirements of an active emitter. To meet the peak short-term power demands, capacitors can be charged and discharged.

Adaptive transflective shell: Originally deployed as a kind of optical spam filter, a shell enclosing the node modulates how much incoming power is absorbed at different wavelengths while also limiting the amount of heat that can be radiated away. By tuning the shell, a node can go from pure black (a perfectly efficient absorber of incoming energy as well as an optimal emitter of local heat) to a perfect mirror (perfectly reflective of incoming energy, but also unable to radiate any heat accumulating in the node). Based on the principle of thin-film optics, the shield can be configured to transmit or reflect broad or narrow notches of wavelength differently. Like the furnace, the shell is somewhat slow to respond to configuration changes. Incoming energy that is not immediately reflected by the shield is absorbed locally as accumulated heat. Heat is radiated with blackbody spectrum effects (hotter nodes try to glow blue-er).

Wide-spectrum sensor: Originally designed to receive and decode incoming messages over a range of wavelengths, the sensor can also monitor heat radiated by the target node or lasers reflected off the target node. The device is extremely precise, but its operation is fundamentally limited by the temperature of the node that contains it. As the temperature increases, the effective number of accurate sensor snapshots per second decreases.

(Optional) Some nodes include a warbler: The warbler is able to spread the optical energy of the emitter over a small range of wavelengths so as to avoid interference on specific channels.


If brands want to take down each others’ networks so badly, why don’t they just call in powerful ground-based attacks the moment they’ve located theirthey opposition? To maintain popular public support (and contracts that have stipulated equal treatment of messages regardless of source, destination, or relaying network), brands want to maintain the image that they are still cooperating with one another. When a node-to-node encounter results in a node loss without any other systems involved, it is easier to quietly write off as an isolated failure rather than evidence of open warfare. (Net neutrality meets the Cold War or whatever.)

Other than the warbler, are there any other differences between nodes? Nodes can vary within and across the brands that own them. In the interest of tutorializing or building a single-player campaign (which serves to train up players for human competition), different nodes can have different numerical and structural configurations. Even for identical nodes, the intelligence of the response policy can be varied as well. (An opponent with a high capacitor rating who doesn’t bother to adjust their emission wavelengths is less of a threat than one with weaker hardware but a more tactically and strategically precise attack behavior.)

Why don’t nodes physically move or rotate to avoid attack or to spread heat? The nodes are almost perfectly spherical, featureless. What means they have for changing their orientation and orbit (e.g. magnetorquers) is not effective on the timescales of combat. (In this non-spatial shooter, you must dodge attacks in spectral transflectivity dimensions.)

Who is the player in this fictional universe? The player is the AI policy operating the node (without real-time guidance from anywhere else). Fictionally, the interaction should be taking place over a very short time period. Perhaps the 2 minute of gameplay represents just 2000ms of fictional real time. These numbers should be fiddled so that any attempt to model light propagation delay makes some sense.

Core Gameplay

During play, players have many possible actions:

Dialing the furnace output up or down

Enabling or disabling the charging state of any inactive capacitors (state changes instantly, but capacitors take some time to charge)

Enqueuing a charged capacitor to be discharged through the emitter (enqueuing actions are instant, but discharging through the emitter takes some time)

Tuning the emitter wavelength (instantly impacting any ongoing emissions -- not a good idea for communication, but useful for attack)

Adapting the shell’s transflectance

Players take actions based on several displays:

Local node state (all displayed with a useful history over time in the current session):

Local temperature

Heat emission rate

Charging status of capacitors

Active/queued status of emitter

Current emitter wavelength (and warbler state)

Remote node state as periodically reported by sensor (subject to local temperature):

Estimated temperature

Estimated heat emission rate

Noisy estimate of the curve of the shell configuration (with variance controlled by emission rate)

If there is an incoming laser, its precise wavelength (with a point sample of warbling effects) and absorption rate

If there is an outgoing laser, its wavelength and precise absorption rate (in such as way that the player can feel out the precise curve of the opponent’s current shell configuration by varying emission wavelength)

Each player’s goal is to cause the opponent’s node to overheat. If the heat of one node reaches a critical limit, that node can be detected by the opposing brand and quickly destroyed by a larger number of low-power emissions from other nodes. Nodes can overheat due to excessive incoming laser energy or simply due to local mismanagement of the furnace and shell. If play continues for more than two minutes (the node has not returned to normal communication mode), the node will be destroyed by its owning brand on account of being unresponsive (under suspicion of being hijacked). Gameplay ends in a loss for both players.

Graphics / User Interface

Without locking the game to a specific platform like PC or mobile, the user interface is imagined to be focused on the technical display of a control panel and sensor readout. Like in FTL, if there is a depiction of the opponent, it is minor and abstract. Closer to Endgame Singularity, the display should be abstract -- you are the AI controlling the node, not a human in a capsule. Like Spaceteam, the player's attention should be on manipulating controls, not looking out into space.

Gameplay Progression

Single player campaign (towards skilling players up for human-vs-human gameplay). Fictionally, you are a human controlling these nodes to produce training data for how an automated policy should act in the future. In the earlier stages of the story (before the cold war heats up), response times are lax and opponents implement only simple scripted strategies (purely deterministic or slightly reactive). Players train up by defeating / cleaning up the older generation of opponent devices, but face nearly fair fights in the multiplayer mode.

In the multiplayer mode (using matchmaking to select opponents of the appropriate estimated skill), players choose between one of three brands to represent in each session (or allow random selection). The configuration of the nodes for each brands can change somewhat over time to balance the metagame, but on any given day, there are only three (human operated) node configurations you might face. Sometimes you’ll face a node of a brand that matches yours (for fictional reasons that should be easy to manufacture).

Design Goals

The game should have a balance of macro- and micro- strategy comparable to a game like Starcraft, but compressed into a very short play session. Because of the time needed to ramp up the furnace, charge capacitors, discharge them through the emitter and the slow response of the tunable shield, attacks need some planning and responses need to be anticipated. At the same time, a quick hand on the shell controls should be able to reflect away most of the energy of an incoming attack.

Like a shooter game, the player’s short-term actions alternate between playing aggressively open to attack and passively waiting out an attack under cover. The player who drops their shell can generate and dissipate a lot of power, but they are open to additions of heat from the opponent. The player who turtles up in a mirror shell is largely impervious to attack, but they must soon ramp down their furnace to avoid self-induced overheating. Running a hot furnace to quickly charge capacitors with a mirror shell is risky because, the moment the capacitors are finished charging, all excess power begins to accumulate as local heat.

Inspirations

In Star Trek, there’s often dialog about “modulating shield harmonics” once an enemy’s weapon systems are understood or “rotating phasor frequencies” once the enemy’s shields are understood. This game design is an attempt to make this kind of activity into the core gameplay. (I haven’t played any modern Star Trek games to see how this element of the fictional universe was interpreted mechanically by others.)

Aspects of how players setup a strategic approach but quickly modify it in response to opponent observations are somewhat inspired by Nidhogg

Aspects of non-positional space combat focused on managing energy, shield, and weapon systems are somewhat inspired by FTL: Faster Than Light.


