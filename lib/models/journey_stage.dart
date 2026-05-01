/// Milestones for the "Hero's Path" journey map.
enum JourneyStage {
  beginning,
  explorersDiscovery,
  mastersQuest;

  String get title => switch (this) {
        JourneyStage.beginning => 'The Beginning',
        JourneyStage.explorersDiscovery => "Explorer's Discovery",
        JourneyStage.mastersQuest => "Master's Quest",
      };
}

