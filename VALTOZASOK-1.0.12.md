# Veszprémi Taxi Driver 1.0.12

- A `HomeController` az alkalmazás indulásakor, állandó GetX bindingként jön létre.
- A HomeScreen már nem hoz létre külön, route-élettartamú HomeControllert.
- A cancel, navigation, OTP, cash collect és review képernyők `Get.find<HomeController>()` hívása navigáció után sem veszti el a controllert.
- Megmaradt a 1.0.11 csendes polling és hibavisszafogás.
