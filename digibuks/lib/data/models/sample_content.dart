class SampleContent {
  // Sample reading content for different books
  static String getSampleContent(String bookId) {
    switch (bookId) {
      case 'book_1': // Mizo Hnamte Chanchin
        return '''
Chapter 1: The Origins

Mizo hnamte hi khawvel ram thar takah chuan an lo chhuak a. An thlahte chu ram leh ram inkarah an lo kal zel a. Hnamte hi an inthlahnaah hian an lo chhuak ta a ni.

Mizo hnamte chanchin hi a thui ber a ni. An ram chu ram thar takah chuan an lo chhuak a. An thlahte chu ram leh ram inkarah an lo kal zel a. Hnamte hi an inthlahnaah hian an lo chhuak ta a ni.

An ram chu ram thar takah chuan an lo chhuak a. An thlahte chu ram leh ram inkarah an lo kal zel a. Hnamte hi an inthlahnaah hian an lo chhuak ta a ni.

Chapter 2: The Journey

Mizo hnamte hi an ram thar takah chuan an lo chhuak a. An thlahte chu ram leh ram inkarah an lo kal zel a. Hnamte hi an inthlahnaah hian an lo chhuak ta a ni.

An ram chu ram thar takah chuan an lo chhuak a. An thlahte chu ram leh ram inkarah an lo kal zel a. Hnamte hi an inthlahnaah hian an lo chhuak ta a ni.
''';

      case 'book_2': // Tlawmngaihna
        return '''
Introduction to Tlawmngaihna

Tlawmngaihna hi Mizo hnamte thil pawimawh ber a ni. He thil hi Mizo hnamte nun dân a ni. Tlawmngaihna chu mi tih duh loh thil tih a ni.

Mizo hnamte hi an ram thar takah chuan an lo chhuak a. An thlahte chu ram leh ram inkarah an lo kal zel a. Hnamte hi an inthlahnaah hian an lo chhuak ta a ni.

Tlawmngaihna hi Mizo hnamte thil pawimawh ber a ni. He thil hi Mizo hnamte nun dân a ni. Tlawmngaihna chu mi tih duh loh thil tih a ni.

The Meaning of Tlawmngaihna

Tlawmngaihna hi Mizo hnamte thil pawimawh ber a ni. He thil hi Mizo hnamte nun dân a ni. Tlawmngaihna chu mi tih duh loh thil tih a ni.

Mizo hnamte hi an ram thar takah chuan an lo chhuak a. An thlahte chu ram leh ram inkarah an lo kal zel a.
''';

      case 'book_3': // Mizo Folk Tales
        return '''
The Legend of the Blue Mountain

Long ago, in the hills of Mizoram, there lived a wise old man named Zawla. He was known throughout the land for his wisdom and kindness. One day, a great challenge came to the village.

The villagers were facing a terrible drought. The crops were failing, and the people were suffering. Zawla knew that he must find a solution. He journeyed to the highest peak, where the spirits of the mountains dwelled.

After many days of travel and meditation, Zawla received a vision. The spirits told him of a hidden spring that would bring water to the village. Following their guidance, he found the spring and brought water to his people.

The Tale of the Brave Hunter

In a small village nestled in the hills, there lived a young hunter named Lal. He was known for his courage and skill with the bow. One day, a fierce tiger began terrorizing the village.

Lal knew he must protect his people. He set out into the forest, tracking the tiger for days. Finally, he found the beast and, using his wisdom and courage, he was able to drive it away from the village.

The villagers celebrated Lal's bravery, and his story became a legend passed down through generations.
''';

      case 'book_4': // The Hills of Mizoram
        return '''
Chapter 1: First Impressions

As I stepped off the bus in Aizawl, the capital of Mizoram, I was immediately struck by the beauty of the hills. The city is built on the slopes, with houses cascading down the mountainside like a waterfall of colors.

The air was crisp and clean, filled with the scent of pine and the sounds of birds. Everywhere I looked, there were vibrant flowers and lush greenery. It was unlike any place I had ever seen.

The people I met were warm and welcoming. Despite the language barrier, their smiles and gestures made me feel at home. I knew this journey would be special.

Chapter 2: Exploring the Villages

My journey took me to several villages in the countryside. Each village had its own character, its own stories. The traditional bamboo houses stood proudly, a testament to the ingenuity of Mizo architecture.

I learned about the community spirit that binds these villages together. The concept of Tlawmngaihna - helping others without expecting anything in return - was evident everywhere I went.

The festivals I witnessed were spectacular. The dances, the music, the colors - everything was a celebration of life and culture.
''';

      case 'book_5': // Mizo Poetry Collection
        return '''
Poem 1: The Hills

Oh, beautiful hills of Mizoram,
Your green slopes touch the sky.
In your valleys, life flows,
Like a river, never dry.

The mist that wraps around you,
Like a shawl of purest white,
Protects the life within you,
From morning until night.

Poem 2: Home

Home is where the heart finds peace,
In the hills of Mizoram.
Where the pines whisper secrets,
And the rivers sing their song.

Home is where the family gathers,
Around the warmth of the fire.
Sharing stories, sharing love,
Fulfilling every desire.

Poem 3: The Seasons

Spring brings flowers,
Summer brings rain,
Autumn brings harvest,
Winter brings rest again.

Each season has its beauty,
Each season has its song,
In the hills of Mizoram,
Where we all belong.
''';

      case 'book_6': // Introduction to Mizo Language
        return '''
Lesson 1: Basic Greetings

Hello - Khawngaih u
Good morning - Tukchhuah nuam
Good evening - Zing nuam
Thank you - Ka lawm e
You're welcome - A va nuam e

Lesson 2: Common Phrases

How are you? - I dam em?
I'm fine - Ka dam e
What is your name? - I hming chu eng nge?
My name is... - Ka hming chu... a ni
Nice to meet you - I hmuh ka lawm e

Lesson 3: Numbers

One - Pakhat
Two - Pahnih
Three - Pathum
Four - Pali
Five - Panga

Six - Paruk
Seven - Pasarih
Eight - Pariat
Nine - Pakua
Ten - Sawm
''';

      default:
        return '''
Chapter 1: Introduction

This is a sample reading content for the book. In a real implementation, this would be loaded from the actual book file (PDF or EPUB).

The content would be displayed here with proper formatting, respecting the reader's font size, line height, and theme preferences.

You can navigate through pages using the controls, add bookmarks, take notes, and customize your reading experience.

Chapter 2: Development

As you continue reading, the app tracks your progress automatically. You can always return to where you left off.

The reading experience is designed to be comfortable and customizable, allowing you to adjust settings to your preference.

Enjoy your reading journey with DigiBuks!
''';
    }
  }

  // Get sample content for EPUB books (formatted text)
  static String getEPUBSampleContent(String bookId) {
    final baseContent = getSampleContent(bookId);
    
    // Format for EPUB display
    return '''
$baseContent

[Page Break]

The reading experience continues here. In a real EPUB file, this would be properly formatted with chapters, paragraphs, and styling.

You can adjust the font size, line height, and theme to make reading more comfortable. The app remembers your preferences for future reading sessions.

[Page Break]

Continue reading to explore more content. The reader supports bookmarks and notes, so you can mark important sections and add your thoughts.
''';
  }
}

