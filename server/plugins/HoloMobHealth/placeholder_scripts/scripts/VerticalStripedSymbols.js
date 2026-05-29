//When HoloMobHealth parses your placeholder, it will replace your defined placeholder text
//with the return value of this function

//In this example we will create a health bar out of vertical stripe characters
function parse() {
	var customname = CustomName;
    var health = Health;
    var maxhealth = MaxHealth;

	var healthyChar = "&a|";
	var halfChar = "&e|";
	var emptyChar = "&7|";
	var heartScale = 20;

	var percentage = (health / maxhealth) * 100;
	var healthpercentagescaled = percentage / 100.0 * heartScale;
	var fullhearts = Math.floor(healthpercentagescaled);

	var text = "";
	var i;

	for (i = 0; i < fullhearts; i++) {
		text += healthyChar;
	}
	if (fullhearts < heartScale) {
		var leftover = healthpercentagescaled - fullhearts;
		if (leftover >= 0.5) {
			text += healthyChar;
		} else {
			text += halfChar;
		}
		for (i = fullhearts + 1; i < heartScale; i++) {
			text += emptyChar;
		}
	}
	return text;
}

parse();