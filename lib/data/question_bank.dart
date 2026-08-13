import 'dart:math';

import '../models/models.dart';

Question q(
  String id,
  GameCategory cat,
  String diff,
  String prompt,
  List<String> options,
  int correct,
  String why,
) =>
    Question(
      id: id,
      category: cat,
      difficulty: diff,
      prompt: prompt,
      options: options,
      correctIndex: correct,
      explanation: why,
    );

final List<Question> kQuestionBank = [
  // Brain
  q('b1', GameCategory.brain, 'easy', 'Which planet is known as the Red Planet?', ['Mars', 'Venus', 'Jupiter', 'Mercury'], 0, 'Mars appears red because iron minerals in its soil have oxidized.'),
  q('b2', GameCategory.brain, 'easy', 'How many sides does a hexagon have?', ['5', '6', '7', '8'], 1, 'A hexagon is a six-sided polygon.'),
  q('b3', GameCategory.brain, 'medium', 'If all Bloops are Razzies and all Razzies are Lazzies, all Bloops are definitely Lazzies.', ['True', 'False', 'Unknown', 'Sometimes'], 0, 'This is a classic transitive logic chain.'),
  q('b4', GameCategory.brain, 'easy', 'What is the next number: 2, 4, 8, 16, ?', ['18', '24', '32', '20'], 2, 'Each term doubles: 16 × 2 = 32.'),
  q('b5', GameCategory.brain, 'medium', 'Which word is the odd one out?', ['Triangle', 'Square', 'Circle', 'Cube'], 3, 'Cube is 3D; the others are 2D shapes.'),
  q('b6', GameCategory.brain, 'easy', 'A leap year has how many days?', ['365', '366', '364', '360'], 1, 'Leap years add February 29.'),
  q('b7', GameCategory.brain, 'hard', 'Find the missing letter: A, C, F, J, O, ?', ['S', 'T', 'U', 'V'], 2, 'Gaps increase by 1: +2, +3, +4, +5, then +6 → U.'),
  q('b8', GameCategory.brain, 'medium', 'Which is a primary color in light (RGB)?', ['Yellow', 'Green', 'Brown', 'White'], 1, 'Light primaries are red, green and blue.'),
  q('b9', GameCategory.brain, 'easy', 'How many minutes are in 2.5 hours?', ['120', '130', '150', '180'], 2, '2.5 × 60 = 150 minutes.'),
  q('b10', GameCategory.brain, 'medium', 'If you rearrange the letters CIFAIPC you get the name of a:', ['City', 'Ocean', 'Animal', 'Country'], 1, 'PACIFIC — an ocean.'),
  q('b11', GameCategory.brain, 'easy', 'What comes next: J, F, M, A, M, J, ?', ['J', 'A', 'S', 'O'], 0, 'First letters of months: July.'),
  q('b12', GameCategory.brain, 'hard', 'A clock shows 3:15. What is the angle between hour and minute hands?', ['0°', '7.5°', '15°', '30°'], 1, 'Minute at 90°, hour at 97.5°, difference 7.5°.'),
  q('b13', GameCategory.brain, 'medium', 'Which number is a palindrome?', ['1232', '3443', '4556', '7891'], 1, '3443 reads the same forwards and backwards.'),
  q('b14', GameCategory.brain, 'easy', 'How many continents are commonly listed?', ['5', '6', '7', '8'], 2, 'Africa, Antarctica, Asia, Australia/Oceania, Europe, North America, South America.'),
  q('b15', GameCategory.brain, 'medium', 'If 5 machines make 5 widgets in 5 minutes, 100 machines make 100 widgets in:', ['5 min', '20 min', '100 min', '1 min'], 0, 'Each machine makes 1 widget / 5 min, so 100 machines still take 5 minutes.'),

  // Math
  q('m1', GameCategory.math, 'easy', '17 + 26 = ?', ['41', '42', '43', '44'], 2, '17 + 26 = 43.'),
  q('m2', GameCategory.math, 'easy', '9 × 8 = ?', ['72', '81', '64', '69'], 0, '9 × 8 = 72.'),
  q('m3', GameCategory.math, 'medium', 'What is 15% of 80?', ['8', '10', '12', '15'], 2, '0.15 × 80 = 12.'),
  q('m4', GameCategory.math, 'easy', 'Square root of 81?', ['7', '8', '9', '10'], 2, '9 × 9 = 81.'),
  q('m5', GameCategory.math, 'medium', '12² = ?', ['124', '144', '132', '156'], 1, '12 × 12 = 144.'),
  q('m6', GameCategory.math, 'hard', 'Solve: 3x + 7 = 22. x = ?', ['3', '4', '5', '6'], 2, '3x = 15, x = 5.'),
  q('m7', GameCategory.math, 'easy', '100 − 37 = ?', ['63', '67', '73', '53'], 0, '100 − 37 = 63.'),
  q('m8', GameCategory.math, 'medium', 'LCM of 4 and 6?', ['8', '10', '12', '24'], 2, 'Least common multiple of 4 and 6 is 12.'),
  q('m9', GameCategory.math, 'medium', 'A triangle’s angles sum to:', ['90°', '180°', '270°', '360°'], 1, 'Interior angles of a triangle total 180°.'),
  q('m10', GameCategory.math, 'hard', 'What is 2⁵?', ['16', '24', '32', '64'], 2, '2⁵ = 32.'),
  q('m11', GameCategory.math, 'easy', 'Half of 96?', ['42', '46', '48', '52'], 2, '96 / 2 = 48.'),
  q('m12', GameCategory.math, 'medium', '7³ = ?', ['243', '343', '441', '218'], 1, '7 × 7 × 7 = 343.'),
  q('m13', GameCategory.math, 'hard', 'Derivative of x² is:', ['x', '2x', 'x²', '2'], 1, 'Power rule: 2x¹ = 2x.'),
  q('m14', GameCategory.math, 'easy', '25 × 4 = ?', ['50', '75', '100', '125'], 2, '25 × 4 = 100.'),
  q('m15', GameCategory.math, 'medium', 'Simplify 18/24', ['2/3', '3/4', '4/5', '5/6'], 1, 'Divide by 6: 3/4.'),

  // Tech
  q('t1', GameCategory.tech, 'easy', 'HTML stands for:', ['HyperText Markup Language', 'HighText Machine Language', 'HyperTool Multi Language', 'Home Tool Markup Language'], 0, 'HTML is HyperText Markup Language.'),
  q('t2', GameCategory.tech, 'easy', 'Which company created Android?', ['Apple', 'Google', 'Microsoft', 'Samsung'], 1, 'Google acquired and developed Android.'),
  q('t3', GameCategory.tech, 'medium', 'RAM is a type of:', ['Permanent storage', 'Volatile memory', 'Network protocol', 'Display standard'], 1, 'RAM loses data when power is off.'),
  q('t4', GameCategory.tech, 'easy', 'Binary 1010 equals:', ['8', '9', '10', '12'], 2, '8+0+2+0 = 10.'),
  q('t5', GameCategory.tech, 'medium', 'Git is used for:', ['Image editing', 'Version control', '3D rendering', 'Email'], 1, 'Git tracks source-code versions.'),
  q('t6', GameCategory.tech, 'medium', 'HTTP status 404 means:', ['OK', 'Forbidden', 'Not Found', 'Server Error'], 2, '404 is resource not found.'),
  q('t7', GameCategory.tech, 'hard', 'Time complexity of binary search is:', ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'], 1, 'Halving the search space each step is O(log n).'),
  q('t8', GameCategory.tech, 'easy', 'A pixel is:', ['A network packet', 'A picture element', 'A CPU core', 'A file format'], 1, 'Pixel = picture element.'),
  q('t9', GameCategory.tech, 'medium', 'SQL is mainly used to:', ['Style pages', 'Query databases', 'Compile apps', 'Draw 3D'], 1, 'SQL is Structured Query Language.'),
  q('t10', GameCategory.tech, 'easy', 'iOS is developed by:', ['Google', 'Apple', 'Amazon', 'Intel'], 1, 'Apple develops iOS.'),
  q('t11', GameCategory.tech, 'hard', 'Which is NOT a programming paradigm?', ['OOP', 'Functional', 'Declarative', 'Photosynthesis'], 3, 'Photosynthesis is biology, not a coding style.'),
  q('t12', GameCategory.tech, 'medium', 'JSON is used to:', ['Compress video', 'Exchange data', 'Encrypt disks', 'Route packets'], 1, 'JSON is a lightweight data format.'),
  q('t13', GameCategory.tech, 'easy', 'CPU stands for:', ['Central Processing Unit', 'Computer Personal Unit', 'Core Power Utility', 'Control Program Unit'], 0, 'The CPU is the central processing unit.'),
  q('t14', GameCategory.tech, 'medium', 'Flutter’s UI language is:', ['Kotlin', 'Swift', 'Dart', 'Java'], 2, 'Flutter apps are written in Dart.'),
  q('t15', GameCategory.tech, 'hard', 'A stack data structure is:', ['FIFO', 'LIFO', 'Random', 'Sorted tree'], 1, 'Stack is last-in, first-out.'),

  // World
  q('w1', GameCategory.world, 'easy', 'Capital of France?', ['Lyon', 'Marseille', 'Paris', 'Nice'], 2, 'Paris is the capital of France.'),
  q('w2', GameCategory.world, 'easy', 'Capital of Pakistan?', ['Karachi', 'Lahore', 'Islamabad', 'Peshawar'], 2, 'Islamabad is the capital.'),
  q('w3', GameCategory.world, 'medium', 'The Great Barrier Reef is in:', ['Brazil', 'Australia', 'India', 'Mexico'], 1, 'It lies off Queensland, Australia.'),
  q('w4', GameCategory.world, 'easy', 'Largest ocean?', ['Atlantic', 'Indian', 'Pacific', 'Arctic'], 2, 'The Pacific is the largest ocean.'),
  q('w5', GameCategory.world, 'medium', 'Mount Everest sits on the border of Nepal and:', ['India', 'China', 'Bhutan', 'Pakistan'], 1, 'Everest is on the Nepal–China (Tibet) border.'),
  q('w6', GameCategory.world, 'easy', 'Capital of Japan?', ['Osaka', 'Kyoto', 'Tokyo', 'Nagoya'], 2, 'Tokyo is Japan’s capital.'),
  q('w7', GameCategory.world, 'medium', 'The Nile River is primarily in:', ['South America', 'Africa', 'Europe', 'Australia'], 1, 'The Nile flows through northeastern Africa.'),
  q('w8', GameCategory.world, 'hard', 'Capital of Canada?', ['Toronto', 'Vancouver', 'Ottawa', 'Montreal'], 2, 'Ottawa is the capital, not Toronto.'),
  q('w9', GameCategory.world, 'easy', 'Which country is shaped like a boot?', ['Spain', 'Italy', 'Greece', 'Portugal'], 1, 'Italy’s peninsula resembles a boot.'),
  q('w10', GameCategory.world, 'medium', 'Sahara Desert is in:', ['Asia', 'Africa', 'Australia', 'North America'], 1, 'The Sahara covers much of North Africa.'),
  q('w11', GameCategory.world, 'hard', 'UAE’s capital is:', ['Dubai', 'Sharjah', 'Abu Dhabi', 'Ajman'], 2, 'Abu Dhabi is the capital of the UAE.'),
  q('w12', GameCategory.world, 'easy', 'Statue of Liberty is in:', ['Los Angeles', 'New York', 'Chicago', 'Miami'], 1, 'It stands in New York Harbor.'),
  q('w13', GameCategory.world, 'medium', 'Amazon rainforest is mostly in:', ['Brazil', 'Chile', 'Argentina', 'Mexico'], 0, 'The majority lies in Brazil.'),
  q('w14', GameCategory.world, 'easy', 'How many countries in the UK?', ['2', '3', '4', '5'], 2, 'England, Scotland, Wales, Northern Ireland.'),
  q('w15', GameCategory.world, 'medium', 'Taj Mahal is in:', ['Delhi', 'Jaipur', 'Agra', 'Mumbai'], 2, 'The Taj Mahal is in Agra, India.'),

  // Science
  q('s1', GameCategory.science, 'easy', 'Water’s chemical formula?', ['CO2', 'H2O', 'O2', 'NaCl'], 1, 'Two hydrogen atoms and one oxygen.'),
  q('s2', GameCategory.science, 'easy', 'Humans breathe in mostly:', ['Oxygen', 'Nitrogen', 'Carbon dioxide', 'Helium'], 1, 'Air is about 78% nitrogen; we use the oxygen portion.'),
  q('s3', GameCategory.science, 'medium', 'Speed of light is roughly:', ['3×10⁸ m/s', '3×10⁶ m/s', '300 m/s', '3×10³ m/s'], 0, 'c ≈ 299,792,458 m/s.'),
  q('s4', GameCategory.science, 'easy', 'The powerhouse of the cell is the:', ['Nucleus', 'Mitochondrion', 'Ribosome', 'Chloroplast'], 1, 'Mitochondria produce ATP.'),
  q('s5', GameCategory.science, 'medium', 'Photosynthesis mainly occurs in:', ['Roots', 'Flowers', 'Leaves', 'Seeds'], 2, 'Chloroplasts in leaves capture light.'),
  q('s6', GameCategory.science, 'hard', 'Atomic number of carbon?', ['6', '8', '12', '14'], 0, 'Carbon has 6 protons.'),
  q('s7', GameCategory.science, 'easy', 'Earth’s gravity acceleration is about:', ['8.8 m/s²', '9.8 m/s²', '10.8 m/s²', '7.8 m/s²'], 1, 'Standard g is 9.8 m/s².'),
  q('s8', GameCategory.science, 'medium', 'DNA stands for:', ['Digital Nerve Acid', 'Deoxyribonucleic Acid', 'Dual Nuclear Atom', 'Dynamic Nucleotide Array'], 1, 'DNA is deoxyribonucleic acid.'),
  q('s9', GameCategory.science, 'easy', 'The Sun is a:', ['Planet', 'Star', 'Comet', 'Moon'], 1, 'The Sun is a G-type main-sequence star.'),
  q('s10', GameCategory.science, 'medium', 'Boiling point of water at 1 atm:', ['90°C', '100°C', '110°C', '80°C'], 1, 'At standard pressure water boils at 100°C.'),
  q('s11', GameCategory.science, 'hard', 'Newton’s third law is about:', ['Inertia', 'F = ma', 'Action-reaction', 'Gravity only'], 2, 'Every action has an equal and opposite reaction.'),
  q('s12', GameCategory.science, 'easy', 'Which gas do plants absorb?', ['Oxygen', 'Nitrogen', 'Carbon dioxide', 'Hydrogen'], 2, 'Plants take in CO₂ for photosynthesis.'),
  q('s13', GameCategory.science, 'medium', 'Blood is pumped by the:', ['Liver', 'Heart', 'Lungs', 'Kidney'], 1, 'The heart pumps blood through the body.'),
  q('s14', GameCategory.science, 'easy', 'Ice is water in which state?', ['Gas', 'Liquid', 'Solid', 'Plasma'], 2, 'Ice is solid H₂O.'),
  q('s15', GameCategory.science, 'hard', 'pH of pure water is about:', ['5', '7', '9', '1'], 1, 'Pure water is neutral, pH 7.'),

  // Word
  q('o1', GameCategory.word, 'easy', 'Choose the correct spelling:', ['Recieve', 'Receive', 'Receve', 'Receeve'], 1, 'i before e except after c: receive.'),
  q('o2', GameCategory.word, 'easy', 'Antonym of “ancient”?', ['Old', 'Modern', 'Historic', 'Aged'], 1, 'Modern is the opposite of ancient.'),
  q('o3', GameCategory.word, 'medium', 'A synonym of “rapid” is:', ['Slow', 'Swift', 'Late', 'Idle'], 1, 'Swift means fast.'),
  q('o4', GameCategory.word, 'easy', 'Plural of “analysis”?', ['Analysiss', 'Analysises', 'Analyses', 'Analysi'], 2, 'The plural is analyses.'),
  q('o5', GameCategory.word, 'medium', 'Which is a palindrome?', ['Arena', 'Level', 'Mind', 'Game'], 1, 'Level reads the same backwards.'),
  q('o6', GameCategory.word, 'hard', '“Ephemeral” means:', ['Lasting forever', 'Short-lived', 'Very large', 'Silent'], 1, 'Ephemeral = lasting a short time.'),
  q('o7', GameCategory.word, 'easy', 'Complete: knowledge is _____', ['power', 'flower', 'tower', 'hour'], 0, 'Classic proverb: knowledge is power.'),
  q('o8', GameCategory.word, 'medium', 'Anagram of “listen”?', ['Silent', 'Tinselx', 'Enlistt', 'Inletsz'], 0, 'Listen → silent.'),
  q('o9', GameCategory.word, 'easy', 'How many vowels in “education”?', ['4', '5', '6', '3'], 1, 'e,u,a,i,o — five vowels.'),
  q('o10', GameCategory.word, 'medium', 'A group of lions is a:', ['Flock', 'Pride', 'School', 'Pack'], 1, 'Lions form a pride.'),
  q('o11', GameCategory.word, 'hard', '“Ubiquitous” means:', ['Rare', 'Found everywhere', 'Invisible', 'Ancient'], 1, 'Ubiquitous = present everywhere.'),
  q('o12', GameCategory.word, 'easy', 'Opposite of “victory”?', ['Win', 'Defeat', 'Score', 'Crown'], 1, 'Defeat is the opposite of victory.'),
  q('o13', GameCategory.word, 'medium', 'Which word is a verb?', ['Bright', 'Quickly', 'Compete', 'Arena'], 2, 'Compete is an action word.'),
  q('o14', GameCategory.word, 'easy', 'Correct article: ___ hour', ['a', 'an', 'the only', 'no article'], 1, 'Hour starts with a vowel sound, so “an”.'),
  q('o15', GameCategory.word, 'hard', '“Cacophony” refers to:', ['Sweet smell', 'Harsh sound', 'Bright light', 'Soft fabric'], 1, 'Cacophony is a harsh mixture of sounds.'),

  // Entertainment
  q('e1', GameCategory.entertainment, 'easy', 'Marvel’s super-soldier is:', ['Iron Man', 'Captain America', 'Thor', 'Hulk'], 1, 'Captain America is the super-soldier.'),
  q('e2', GameCategory.entertainment, 'easy', 'Mario is a mascot of:', ['Sony', 'Sega', 'Nintendo', 'Xbox'], 2, 'Mario is Nintendo’s icon.'),
  q('e3', GameCategory.entertainment, 'medium', 'The Beatles were from:', ['New York', 'Liverpool', 'London only', 'Dublin'], 1, 'The Beatles formed in Liverpool.'),
  q('e4', GameCategory.entertainment, 'easy', 'Harry Potter’s school is:', ['Durmstrang', 'Hogwarts', 'Beauxbatons', 'Ilvermorny'], 1, 'Hogwarts School of Witchcraft and Wizardry.'),
  q('e5', GameCategory.entertainment, 'medium', 'Oscar is awarded by:', ['BAFTA', 'AMPAS', 'Golden Globes', 'Emmy Academy'], 1, 'The Academy of Motion Picture Arts and Sciences.'),
  q('e6', GameCategory.entertainment, 'easy', 'Pikachu is a:', ['Digimon', 'Pokémon', 'Yo-kai', 'Robot'], 1, 'Pikachu is a Pokémon.'),
  q('e7', GameCategory.entertainment, 'medium', '“Inception” was directed by:', ['Spielberg', 'Nolan', 'Tarantino', 'Cameron'], 1, 'Christopher Nolan directed Inception.'),
  q('e8', GameCategory.entertainment, 'easy', 'FIFA World Cup is played every:', ['2 years', '3 years', '4 years', '5 years'], 2, 'The men’s World Cup is every four years.'),
  q('e9', GameCategory.entertainment, 'hard', 'The first Pokémon games were released on:', ['PlayStation', 'Game Boy', 'Nintendo 64', 'Sega Genesis'], 1, 'Red/Green/Blue launched on Game Boy.'),
  q('e10', GameCategory.entertainment, 'medium', 'Stranger Things is set mainly in the:', ['1990s', '1980s', '2000s', '1970s'], 1, 'The show is steeped in 1980s culture.'),
  q('e11', GameCategory.entertainment, 'easy', 'Elsa is a character from:', ['Moana', 'Frozen', 'Tangled', 'Brave'], 1, 'Elsa is from Frozen.'),
  q('e12', GameCategory.entertainment, 'medium', 'GTA is published by:', ['EA', 'Ubisoft', 'Rockstar', 'Activision'], 2, 'Rockstar Games publishes GTA.'),
  q('e13', GameCategory.entertainment, 'easy', 'A wicket is used in:', ['Football', 'Cricket', 'Tennis', 'Golf'], 1, 'Cricket uses wickets.'),
  q('e14', GameCategory.entertainment, 'hard', 'The composer of the Star Wars theme is:', ['Zimmer', 'Williams', 'Horner', 'Elfman'], 1, 'John Williams wrote the Star Wars score.'),
  q('e15', GameCategory.entertainment, 'medium', 'Among Us became a hit around:', ['2012', '2018–2020', '2005', '2024'], 1, 'It exploded in popularity in 2020.'),

  q('b16', GameCategory.brain, 'easy', 'How many hours in a week?', ['168', '144', '120', '196'], 0, '7 × 24 = 168 hours.'),
  q('b17', GameCategory.brain, 'medium', 'If 1=3, 2=3, 3=5, 4=4, 5=4, then 6=?', ['3', '5', '6', '4'], 0, 'Letters in the English word: SIX has three.'),
  q('t16', GameCategory.tech, 'easy', 'Wi-Fi is a:', ['Cable standard', 'Wireless network', 'Battery type', 'CPU brand'], 1, 'Wi-Fi is a wireless local network technology.'),
  q('t17', GameCategory.tech, 'medium', 'An API lets programs:', ['Talk to each other', 'Cool the GPU', 'Print paper', 'Charge phones'], 0, 'APIs are interfaces between software.'),
  q('w16', GameCategory.world, 'easy', 'Capital of India?', ['Mumbai', 'New Delhi', 'Bengaluru', 'Kolkata'], 1, 'New Delhi is the capital of India.'),
  q('s16', GameCategory.science, 'easy', 'Humans have how many bones (adult)?', ['186', '206', '226', '300'], 1, 'Adults typically have 206 bones.'),
  q('o16', GameCategory.word, 'easy', 'Synonym of “begin”?', ['Start', 'Stop', 'Sleep', 'Store'], 0, 'Start means begin.'),
  q('s19', GameCategory.science, 'easy', 'What gas do plants absorb for photosynthesis?', ['Oxygen', 'Nitrogen', 'Carbon dioxide', 'Helium'], 2, 'Plants take in CO₂ and release oxygen.'),
  q('s20', GameCategory.science, 'medium', 'DNA’s shape is commonly described as a:', ['Zigzag', 'Double helix', 'Cube', 'Spiral staircase of cubes'], 1, 'Watson and Crick described DNA as a double helix.'),
  q('e16', GameCategory.entertainment, 'easy', 'Which streaming app is known for original series like Stranger Things?', ['Netflix', 'Excel', 'Dropbox', 'Zoom'], 0, 'Stranger Things is a Netflix original.'),
  q('e17', GameCategory.entertainment, 'medium', 'Who directed Inception?', ['James Cameron', 'Christopher Nolan', 'Ridley Scott', 'Denis Villeneuve'], 1, 'Christopher Nolan directed Inception (2010).'),
  q('w18', GameCategory.world, 'medium', 'Mount Everest sits on the border of Nepal and:', ['India', 'China', 'Bhutan', 'Pakistan'], 1, 'Everest’s summit is on the Nepal–China (Tibet) border.'),
  q('t18', GameCategory.tech, 'easy', 'www typically stands for:', ['World Wide Web', 'Wide Wireless Wave', 'Web Window Widget', 'Work With Windows'], 0, 'WWW is the World Wide Web.'),
  q('b18', GameCategory.brain, 'medium', 'Which is heavier: a kilogram of feathers or a kilogram of steel?', ['Steel', 'Feathers', 'They weigh the same', 'Depends on gravity'], 2, 'Both are one kilogram — same mass.'),
  q('m16', GameCategory.math, 'easy', 'What is 11 × 11?', ['111', '121', '131', '101'], 1, '11 × 11 = 121.'),
  q('sc18', GameCategory.science, 'easy', 'Water boils at sea level at:', ['90°C', '100°C', '120°C', '80°C'], 1, 'At standard pressure, water boils at 100°C.'),
  q('w17', GameCategory.world, 'easy', 'The Nile is a famous:', ['Desert', 'Mountain', 'River', 'City'], 2, 'The Nile is a major African river.'),
  q('e18', GameCategory.entertainment, 'easy', 'A grammy is an award mainly for:', ['Music', 'Architecture', 'Chess', 'Cooking'], 0, 'The Grammys honor recorded music.'),
  q('m17', GameCategory.math, 'medium', 'What is 30% of 50?', ['10', '15', '20', '25'], 1, '0.3 × 50 = 15.'),
  q('t19', GameCategory.tech, 'easy', 'A URL is a:', ['Web address', 'Battery', 'Speaker', 'Password vault'], 0, 'URL means Uniform Resource Locator — a web address.'),
  q('s21', GameCategory.science, 'easy', 'The Earth orbits the:', ['Moon', 'Sun', 'Mars', 'ISS'], 1, 'Earth completes one orbit of the Sun about every 365 days.'),
  q('w19', GameCategory.world, 'easy', 'Tokyo is the capital of:', ['China', 'Japan', 'South Korea', 'Thailand'], 1, 'Tokyo is the capital of Japan.'),
  q('o17', GameCategory.word, 'easy', 'Antonym of “hot”?', ['Cold', 'Warm', 'Boil', 'Sun'], 0, 'Cold is the opposite of hot.'),
  q('b19', GameCategory.brain, 'easy', 'How many degrees in a right angle?', ['45', '90', '180', '360'], 1, 'A right angle is 90°.'),
  q('b20', GameCategory.brain, 'hard', 'If yesterday was Thursday, what day is two days after tomorrow?', ['Sunday', 'Monday', 'Tuesday', 'Saturday'], 1, 'Today is Friday, tomorrow Saturday, two days after that is Monday.'),
  q('m18', GameCategory.math, 'easy', 'What is 14 × 5?', ['60', '70', '75', '80'], 1, '14 × 5 = 70.'),
  q('m19', GameCategory.math, 'hard', 'What is the median of 3, 9, 4, 7, 5?', ['4', '5', '7', '9'], 1, 'Sorted 3,4,5,7,9 — the middle value is 5.'),
  q('t20', GameCategory.tech, 'medium', 'HTTPS adds which layer over HTTP?', ['Compression', 'TLS encryption', '3D graphics', 'Battery saving'], 1, 'HTTPS is HTTP over TLS/SSL.'),
  q('t21', GameCategory.tech, 'easy', 'A GPU is mainly for:', ['Graphics processing', 'Printing', 'Cooling air', 'Storing emails'], 0, 'A GPU accelerates graphics (and many parallel jobs).'),
  q('w20', GameCategory.world, 'easy', 'The Amazon River is primarily in:', ['Africa', 'South America', 'Europe', 'Australia'], 1, 'The Amazon basin is in South America.'),
  q('w21', GameCategory.world, 'medium', 'How many time zones does Russia span?', ['3', '7', '11', '24'], 2, 'Russia spans 11 time zones.'),
  q('s22', GameCategory.science, 'easy', 'Lightning is a form of:', ['Electricity', 'Magnetism only', 'Sound', 'Gravity'], 0, 'Lightning is a giant electrostatic discharge.'),
  q('s23', GameCategory.science, 'medium', 'The largest planet in our solar system is:', ['Earth', 'Saturn', 'Jupiter', 'Neptune'], 2, 'Jupiter is the largest planet.'),
  q('o18', GameCategory.word, 'medium', 'A homophone of “pair” is:', ['Pear', 'Peerless', 'Pure', 'Pour'], 0, 'Pair and pear sound the same.'),
  q('o19', GameCategory.word, 'easy', 'Plural of “mouse” (animal)?', ['Mouses', 'Mice', 'Mousees', 'Meese'], 1, 'The common plural is mice.'),
  q('e19', GameCategory.entertainment, 'easy', 'Sherlock Holmes is a:', ['Detective', 'Chef', 'Astronaut', 'Footballer'], 0, 'Holmes is a fictional detective.'),
  q('e20', GameCategory.entertainment, 'medium', 'The Olympics are held every:', ['2 years (summer or winter cycle)', '6 years', '10 years', '1 year'], 0, 'Summer and winter Games alternate every two years.'),
  q('b21', GameCategory.brain, 'easy', 'How many zeros in one thousand?', ['2', '3', '4', '6'], 1, '1,000 has three zeros.'),
  q('m20', GameCategory.math, 'easy', 'What is 9 × 7?', ['56', '63', '72', '81'], 1, '9 × 7 = 63.'),
  q('t22', GameCategory.tech, 'medium', 'A CPU cache is used to:', ['Store frequently used data closer to the chip', 'Cool the battery', 'Print pages', 'Record the screen'], 0, 'Cache sits near the CPU to speed up repeated memory access.'),
  q('w22', GameCategory.world, 'easy', 'The Sahara is a:', ['Rainforest', 'Desert', 'Ocean', 'Mountain range'], 1, 'The Sahara is the world’s largest hot desert.'),
  q('s24', GameCategory.science, 'easy', 'Humans typically have how many lungs?', ['1', '2', '3', '4'], 1, 'A healthy human has two lungs.'),
  q('o20', GameCategory.word, 'easy', 'A synonym of “happy” is:', ['Joyful', 'Angry', 'Tired', 'Silent'], 0, 'Joyful means happy.'),
  q('e21', GameCategory.entertainment, 'easy', 'Batman operates mainly in:', ['Metropolis', 'Gotham', 'Wakanda', 'Asgard'], 1, 'Batman’s city is Gotham.'),
  q('b22', GameCategory.brain, 'medium', 'Which day comes after Friday?', ['Thursday', 'Saturday', 'Sunday', 'Monday'], 1, 'The weekday after Friday is Saturday.'),
  q('m21', GameCategory.math, 'easy', 'What is 100 ÷ 4?', ['20', '25', '40', '50'], 1, '100 ÷ 4 = 25.'),
  q('t23', GameCategory.tech, 'easy', 'A PDF is mainly a:', ['Document format', 'Video codec', 'Wi-Fi band', 'CPU socket'], 0, 'PDF is Portable Document Format.'),
  q('w23', GameCategory.world, 'easy', 'The capital of Germany is:', ['Munich', 'Frankfurt', 'Berlin', 'Hamburg'], 2, 'Berlin is the capital of Germany.'),
  q('s25', GameCategory.science, 'medium', 'Sound travels fastest through:', ['Air', 'Water', 'Steel', 'Vacuum'], 2, 'Sound needs a medium and is fastest in dense solids like steel.'),
  q('o21', GameCategory.word, 'easy', 'The opposite of “arrive” is:', ['Depart', 'Enter', 'Visit', 'Stay'], 0, 'Depart is the opposite of arrive.'),
  q('e22', GameCategory.entertainment, 'easy', 'A touchdown is scored in:', ['Tennis', 'American football', 'Golf', 'Chess'], 1, 'A touchdown is worth six points in American football.'),
];

List<Question> questionsFor(GameCategory category) {
  if (category == GameCategory.math) {
    return [
      ...kQuestionBank.where((e) => e.category == GameCategory.math),
      for (var i = 0; i < 50; i++) generateMath(),
    ];
  }
  if (category == GameCategory.word) {
    return [
      ...kQuestionBank.where((e) => e.category == GameCategory.word),
      for (var i = 0; i < 12; i++) generateScramble(),
    ];
  }
  return kQuestionBank.where((e) => e.category == category).toList();
}

List<Question> mixedQuestions() {
  final mix = [
    ...kQuestionBank,
    for (var i = 0; i < 16; i++) generateMath(),
    for (var i = 0; i < 6; i++) generateScramble(),
  ]..shuffle();
  return mix;
}

List<Question> filterByDifficulty(List<Question> source, String difficulty) {
  if (difficulty == 'all' || difficulty.isEmpty) return source;
  final hit = source.where((q) => q.difficulty == difficulty).toList();
  return hit.length >= 4 ? hit : source;
}

Question generateMath([Random? rng]) {
  final r = rng ?? Random();
  final tier = r.nextInt(3);
  late String text;
  late int answer;
  late String why;
  if (tier == 0) {
    final a = 8 + r.nextInt(40);
    final b = 3 + r.nextInt(25);
    final add = r.nextBool();
    text = add ? '$a + $b = ?' : '$a − $b = ?';
    answer = add ? a + b : a - b;
    why = add ? '$a + $b = $answer.' : '$a − $b = $answer.';
  } else if (tier == 1) {
    final a = 4 + r.nextInt(12);
    final b = 3 + r.nextInt(9);
    text = '$a × $b = ?';
    answer = a * b;
    why = '$a × $b = $answer.';
  } else {
    final b = 2 + r.nextInt(9);
    final m = 2 + r.nextInt(12);
    final a = b * m;
    text = '$a ÷ $b = ?';
    answer = m;
    why = '$a ÷ $b = $answer.';
  }
  final opts = <int>{answer};
  while (opts.length < 4) {
    opts.add(answer + r.nextInt(17) - 8);
  }
  final list = opts.toList()..shuffle(r);
  return Question(
    id: 'math-live-${r.nextInt(1 << 30)}',
    category: GameCategory.math,
    difficulty: tier == 0 ? 'easy' : (tier == 1 ? 'medium' : 'hard'),
    prompt: text,
    options: [for (final n in list) '$n'],
    correctIndex: list.indexOf(answer),
    explanation: why,
  );
}

Question generateScramble([Random? rng]) {
  final r = rng ?? Random();
  const words = ['ARENA', 'NEON', 'MIND', 'RUSH', 'LEVEL', 'STREAK', 'QUEST', 'LOGIC', 'PIXEL', 'CHAMP'];
  final word = words[r.nextInt(words.length)];
  final chars = word.split('')..shuffle(r);
  var scrambled = chars.join();
  if (scrambled == word) scrambled = word.split('').reversed.join();
  final decoys = [...words]..remove(word)..shuffle(r);
  final options = [word, decoys[0], decoys[1], decoys[2]]..shuffle(r);
  return Question(
    id: 'word-live-${r.nextInt(1 << 30)}',
    category: GameCategory.word,
    difficulty: 'medium',
    prompt: 'Unscramble: $scrambled',
    options: options,
    correctIndex: options.indexOf(word),
    explanation: 'The letters spell $word.',
  );
}
