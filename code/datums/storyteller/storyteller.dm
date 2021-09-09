/// Can create antags using dynamic.
#define CREATES_DYNAMIC_ANTAGS (1 << 0)
/// Can create antags using events.
#define CREATES_EVENT_ANTAGS (1 << 1)
/// Has the power to mess with antag objectives. Will listen for key events during the shift and may create antags with specially tailored objective datums, or modify existing antag objectives.
#define INTERFERES_WITH_OBJECTIVES (1 << 2)

/**
 * An AI storyteller intended to control various game systems such as random events triggering
 * and dynamic creating antags.
 *
 * Has a lot of power. Can fire off events, create antags and modify objectives as a result of
 * various shift happenings.
 */
/datum/storyteller
	/// Name of the storyteller. Can be used on the end of round screen or elsewhere.
	var/name = "Paul the Passive"
	/// Description of the storyteller. Useful to display on admin tools so the admins know what they're in for.
	var/description = "A passive storyteller that prefers to watch and not interfere. Does not interact with the shift. Disables random events. Creates no antags. Perfect for when an admin wants to assume direct control for an event!"
	/// The desire for this storyteller to create antags. The higher the value, the more often this storyteller will create new antags. Value of 0 means it will never create antags. (Extended)
	var/create_antag_desire = 0
	/// The percentage of the living crew that the storyteller wishes to see as antags.
	var/threat_count_percentage = 0
	/// The higher the thirst for destruction, the more the storyteller will emphasise station destroying events, antags and objectives over more passive/peaceful ones. A value of 0 means the storyteller will create low-destruction antags with passive objectives such as theft.
	var/destruction_desire = 0
	/// Storytellers with a high random event desire are more likely to trigger random events and trigger them more often. They're also more likely to combo events together with antag creation or fire events in response to shift happenings. A value of 0 means no random events will fire.
	var/random_event_desire = 0
	/// Bitfield showcasing which traits the storyteller has available to them. These traits decide what the storyteller can and cannot do and form the backbone of its behaviours.
	var/storyteller_traits = NONE

/// Ellie Extended creates no direct antags and instead interacts with the shift entirely through the random events system.
/datum/storyteller/ellie_extended
	name = "Ellie Extended"
	description = "Ellie Extended hates dynamic rulesets with a fiery passion. She much prefers to balance the fate of the shift exclusively using events, carefully limiting the number of active threats."
	create_antag_desire = 0
	threat_count_desire = 1
	destruction_desire = 50
	random_event_desire = 50
	storyteller_traits = CREATES_EVENT_ANTAGS

/datum/storyteller/theo_threatening
	name = "Theo Threatening"
	description = "A terrifying storyteller who basks in the crew's suffering. Pushes all the buttons to make for highly threatening and highly stressful shifts."
	create_antag_desire = 100
	threat_count_desire =
