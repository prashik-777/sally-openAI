import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sally/openai_service.dart';
import 'package:sally/pallete.dart';
import 'package:sally/feature_box.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();

  String lastWords = '';

  final OpenAIService openAIService = OpenAIService();

  String? generatedContent;
  String? generatedImageUrl;

  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('Sally')),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //virtual assisstant image part
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage('assets/images/npa.png'))),
                  )
                ],
              ),
            ),
            //salutation part
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 40)
                        .copyWith(top: 30),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Pallete.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(20).copyWith(
                          topLeft: Radius.zero,
                        )),
                    child:  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text( 
                        generatedContent==null
                        ? 'Hello! This is Sally, how may I help you?' 
                        : generatedContent!,
                        style: TextStyle(
                            fontFamily: 'Cera Pro',
                            color: Pallete.mainFontColor,
                            fontSize: generatedContent == null 
                              ? 25
                              : 18,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
      
            SlideInLeft(
              child: Visibility(
                 visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(
                    top: 10,
                    left: 25,
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Here are a few suggestions',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
      
            //featuresss lisstttt
      
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SlideInLeft(
                      delay: Duration(milliseconds: start),
                      child: const FeatureBox(
                        color: Pallete.firstSuggestionBoxColor,
                        headerText: 'ChatGPT',
                        descText:
                            'A smarter way to stay organized and informed with ChatGPT',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + delay),
                      child: const FeatureBox(
                        color: Pallete.secondSuggestionBoxColor,
                        headerText: 'Dall-E',
                        descText:
                            'Generate amazing AI images .. Try saying Generate an image of .....',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + delay + delay),
                      child: const FeatureBox(
                        color: Pallete.thirdSuggestionBoxColor,
                        headerText: 'Smart Voice Assistant',
                        descText:
                            'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            final speech = await openAIService.isArtPromptAPI(lastWords);
            if (speech.contains('https')) {
              generatedImageUrl = speech;
              generatedContent = null;
              setState(() {});
            }
            else{
              generatedImageUrl = null;
              generatedContent = speech;
              setState(() {});
              await systemSpeak(speech);
            }
            
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        child: Icon(speechToText.isListening? Icons.stop : Icons.mic),
      ),
    );
  }
}
