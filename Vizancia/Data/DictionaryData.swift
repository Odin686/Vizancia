import Foundation

// MARK: - Dictionary Entry
struct DictionaryEntry: Identifiable, Hashable {
    let id: String
    let term: String
    let definition: String
    let category: DictionaryCategory
    let relatedTerms: [String]
    let example: String?

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: DictionaryEntry, rhs: DictionaryEntry) -> Bool { lhs.id == rhs.id }
}

// MARK: - Dictionary Category
enum DictionaryCategory: String, CaseIterable, Identifiable {
    case aiCore = "AI Basics"
    case machineLearning = "Machine Learning"
    case neuralNetworks = "Neural Networks"
    case nlp = "Language AI"
    case computerVision = "Computer Vision"
    case generativeAI = "Generative AI"
    case ethics = "AI Ethics"
    case computerScience = "Computer Science"
    case math = "Math & Stats"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .aiCore: return "brain.head.profile"
        case .machineLearning: return "gearshape.2.fill"
        case .neuralNetworks: return "network"
        case .nlp: return "text.bubble.fill"
        case .computerVision: return "eye.fill"
        case .generativeAI: return "sparkles"
        case .ethics: return "scale.3d"
        case .computerScience: return "desktopcomputer"
        case .math: return "function"
        }
    }

    var color: String {
        switch self {
        case .aiCore: return "aiPrimary"
        case .machineLearning: return "aiSecondary"
        case .neuralNetworks: return "aiOrange"
        case .nlp: return "aiBlue"
        case .computerVision: return "aiPink"
        case .generativeAI: return "aiIndigo"
        case .ethics: return "aiWarning"
        case .computerScience: return "aiGreen"
        case .math: return "aiCyan"
        }
    }
}

// MARK: - All Dictionary Entries
struct AIDictionary {
    static let entries: [DictionaryEntry] = aiCore + machineLearning + neuralNetworks + nlp + computerVision + generativeAI + ethics + computerScience + math

    // MARK: - AI Core
    private static let aiCore: [DictionaryEntry] = [
        DictionaryEntry(
            id: "ai",
            term: "Artificial Intelligence (AI)",
            definition: "Computer systems that can do tasks that normally need human intelligence — like understanding language, recognizing pictures, or making decisions.",
            category: .aiCore,
            relatedTerms: ["Machine Learning", "Neural Network"],
            example: "Siri, Alexa, and Google Assistant are all AI systems."
        ),
        DictionaryEntry(
            id: "agi",
            term: "Artificial General Intelligence (AGI)",
            definition: "A type of AI that could understand and learn any task a human can — something that doesn't exist yet but researchers are working toward.",
            category: .aiCore,
            relatedTerms: ["Artificial Intelligence", "Narrow AI"],
            example: nil
        ),
        DictionaryEntry(
            id: "narrow_ai",
            term: "Narrow AI",
            definition: "AI that is really good at one specific thing but can't do other tasks. All AI today is narrow AI.",
            category: .aiCore,
            relatedTerms: ["AGI", "Artificial Intelligence"],
            example: "A chess AI can beat world champions but can't write a poem."
        ),
        DictionaryEntry(
            id: "algorithm",
            term: "Algorithm",
            definition: "A step-by-step set of instructions that tells a computer exactly how to solve a problem or complete a task.",
            category: .aiCore,
            relatedTerms: ["Model", "Program"],
            example: "A recipe is like an algorithm for cooking."
        ),
        DictionaryEntry(
            id: "model",
            term: "Model",
            definition: "A mathematical representation that an AI system learns from data. It's like the AI's brain — it captures patterns and uses them to make predictions.",
            category: .aiCore,
            relatedTerms: ["Training", "Parameters"],
            example: "GPT-4, Claude, and Gemini are all AI models."
        ),
        DictionaryEntry(
            id: "training",
            term: "Training",
            definition: "The process of teaching an AI by showing it lots of examples so it can learn patterns and get better at a task.",
            category: .aiCore,
            relatedTerms: ["Dataset", "Model", "Epoch"],
            example: "To train an image AI, you might show it millions of labeled photos."
        ),
        DictionaryEntry(
            id: "inference",
            term: "Inference",
            definition: "When a trained AI uses what it learned to make predictions or decisions on new data it hasn't seen before.",
            category: .aiCore,
            relatedTerms: ["Training", "Model"],
            example: "When you ask ChatGPT a question, it's doing inference."
        ),
        DictionaryEntry(
            id: "dataset",
            term: "Dataset",
            definition: "A collection of data used to train or test an AI. Think of it like a textbook the AI studies from.",
            category: .aiCore,
            relatedTerms: ["Training", "Label"],
            example: "ImageNet is a famous dataset with millions of labeled images."
        ),
        DictionaryEntry(
            id: "parameters",
            term: "Parameters",
            definition: "The numbers inside an AI model that get adjusted during training. More parameters usually means the model can learn more complex patterns.",
            category: .aiCore,
            relatedTerms: ["Model", "Training", "Weights"],
            example: "GPT-4 has over a trillion parameters."
        ),
        DictionaryEntry(
            id: "automation",
            term: "Automation",
            definition: "Using technology to perform tasks without human help. AI makes automation smarter by letting machines handle complex decisions.",
            category: .aiCore,
            relatedTerms: ["Artificial Intelligence", "Robot"],
            example: "Self-checkout machines automate the cashier's job."
        ),
        DictionaryEntry(
            id: "chatbot",
            term: "Chatbot",
            definition: "An AI program that can have a conversation with you by understanding and responding to text or voice messages.",
            category: .aiCore,
            relatedTerms: ["NLP", "Large Language Model"],
            example: "ChatGPT, Claude, and Gemini are advanced chatbots."
        ),
        DictionaryEntry(
            id: "robot",
            term: "Robot",
            definition: "A machine that can carry out tasks automatically. Some robots use AI to make decisions, while others just follow fixed instructions.",
            category: .aiCore,
            relatedTerms: ["Automation", "Artificial Intelligence"],
            example: "Roomba vacuum robots use sensors and AI to navigate your home."
        ),
    ]

    // MARK: - Machine Learning
    private static let machineLearning: [DictionaryEntry] = [
        DictionaryEntry(
            id: "ml",
            term: "Machine Learning (ML)",
            definition: "A type of AI where computers learn from data instead of being explicitly programmed with rules. The more data they see, the better they get.",
            category: .machineLearning,
            relatedTerms: ["Deep Learning", "Supervised Learning"],
            example: "Spam filters learn to recognize junk email by studying examples."
        ),
        DictionaryEntry(
            id: "supervised",
            term: "Supervised Learning",
            definition: "Training an AI using labeled examples — you tell it the right answer for each example so it can learn the pattern.",
            category: .machineLearning,
            relatedTerms: ["Unsupervised Learning", "Label", "Classification"],
            example: "Showing an AI 1000 pictures of cats labeled 'cat' and 1000 dogs labeled 'dog'."
        ),
        DictionaryEntry(
            id: "unsupervised",
            term: "Unsupervised Learning",
            definition: "Training an AI on data without labels — the AI has to find patterns and groups on its own.",
            category: .machineLearning,
            relatedTerms: ["Supervised Learning", "Clustering"],
            example: "Grouping customers by shopping behavior without pre-defined categories."
        ),
        DictionaryEntry(
            id: "reinforcement",
            term: "Reinforcement Learning",
            definition: "Training an AI by rewarding good actions and penalizing bad ones — like training a dog with treats. The AI learns through trial and error.",
            category: .machineLearning,
            relatedTerms: ["Reward", "Agent"],
            example: "AlphaGo learned to play Go by playing millions of games against itself."
        ),
        DictionaryEntry(
            id: "classification",
            term: "Classification",
            definition: "An AI task where the model sorts things into categories — like deciding if an email is spam or not spam.",
            category: .machineLearning,
            relatedTerms: ["Regression", "Supervised Learning"],
            example: "A medical AI classifying an X-ray as 'healthy' or 'needs review'."
        ),
        DictionaryEntry(
            id: "regression",
            term: "Regression",
            definition: "An AI task where the model predicts a number — like estimating a house's price based on its size, location, and age.",
            category: .machineLearning,
            relatedTerms: ["Classification", "Prediction"],
            example: "Predicting tomorrow's temperature based on weather patterns."
        ),
        DictionaryEntry(
            id: "overfitting",
            term: "Overfitting",
            definition: "When an AI memorizes the training data too well and can't handle new, unseen data. It's like studying only the practice test and failing the real exam.",
            category: .machineLearning,
            relatedTerms: ["Underfitting", "Generalization"],
            example: nil
        ),
        DictionaryEntry(
            id: "label",
            term: "Label",
            definition: "A tag or answer attached to a piece of training data. Labels tell the AI what the correct output should be.",
            category: .machineLearning,
            relatedTerms: ["Supervised Learning", "Dataset"],
            example: "A photo tagged as 'sunset' is a labeled example."
        ),
        DictionaryEntry(
            id: "feature",
            term: "Feature",
            definition: "An individual measurable property of data that the AI uses to learn patterns. Features are the clues the AI looks at.",
            category: .machineLearning,
            relatedTerms: ["Dataset", "Model"],
            example: "For a house price model, features might be square footage, number of bedrooms, and zip code."
        ),
        DictionaryEntry(
            id: "epoch",
            term: "Epoch",
            definition: "One complete pass through the entire training dataset. Training usually takes many epochs for the AI to learn well.",
            category: .machineLearning,
            relatedTerms: ["Training", "Batch"],
            example: nil
        ),
        DictionaryEntry(
            id: "clustering",
            term: "Clustering",
            definition: "Grouping similar data points together without being told what the groups should be. The AI discovers the groups on its own.",
            category: .machineLearning,
            relatedTerms: ["Unsupervised Learning", "Classification"],
            example: "Grouping news articles by topic automatically."
        ),
        DictionaryEntry(
            id: "bias_ml",
            term: "Bias (in ML)",
            definition: "When an AI model consistently makes errors in one direction — often because the training data was unbalanced or not representative.",
            category: .machineLearning,
            relatedTerms: ["Fairness", "Dataset"],
            example: "A hiring AI trained mostly on male resumes might unfairly favor men."
        ),
        DictionaryEntry(
            id: "accuracy",
            term: "Accuracy",
            definition: "The percentage of correct predictions an AI makes. Higher accuracy means the model is better at its task.",
            category: .machineLearning,
            relatedTerms: ["Precision", "Recall"],
            example: "A weather AI that correctly predicts rain 85 out of 100 times has 85% accuracy."
        ),
        DictionaryEntry(
            id: "deep_learning",
            term: "Deep Learning",
            definition: "A type of machine learning that uses neural networks with many layers. 'Deep' refers to the many layers stacked together.",
            category: .machineLearning,
            relatedTerms: ["Neural Network", "Machine Learning"],
            example: "Deep learning powers face recognition, self-driving cars, and language AI."
        ),
    ]

    // MARK: - Neural Networks
    private static let neuralNetworks: [DictionaryEntry] = [
        DictionaryEntry(
            id: "neural_net",
            term: "Neural Network",
            definition: "An AI system inspired by the human brain, made of layers of connected nodes (neurons) that process information and learn patterns.",
            category: .neuralNetworks,
            relatedTerms: ["Deep Learning", "Neuron", "Layer"],
            example: nil
        ),
        DictionaryEntry(
            id: "neuron",
            term: "Neuron (Node)",
            definition: "The basic unit of a neural network. Each neuron takes in numbers, does a calculation, and passes the result to the next layer.",
            category: .neuralNetworks,
            relatedTerms: ["Neural Network", "Activation Function"],
            example: nil
        ),
        DictionaryEntry(
            id: "layer",
            term: "Layer",
            definition: "A group of neurons in a neural network. Data flows from the input layer, through hidden layers, to the output layer.",
            category: .neuralNetworks,
            relatedTerms: ["Neural Network", "Neuron"],
            example: nil
        ),
        DictionaryEntry(
            id: "weights",
            term: "Weights",
            definition: "Numbers that determine how strongly one neuron's output affects the next. Training adjusts the weights to improve accuracy.",
            category: .neuralNetworks,
            relatedTerms: ["Parameters", "Training"],
            example: "Think of weights like volume knobs — they control how loud each connection is."
        ),
        DictionaryEntry(
            id: "activation_fn",
            term: "Activation Function",
            definition: "A math function that decides whether a neuron should 'fire' or stay quiet, based on its input. It adds non-linearity so the network can learn complex patterns.",
            category: .neuralNetworks,
            relatedTerms: ["Neuron", "ReLU"],
            example: nil
        ),
        DictionaryEntry(
            id: "backpropagation",
            term: "Backpropagation",
            definition: "The main way neural networks learn: after making a prediction, the error is sent backward through the network to adjust the weights and reduce mistakes.",
            category: .neuralNetworks,
            relatedTerms: ["Weights", "Gradient Descent"],
            example: nil
        ),
        DictionaryEntry(
            id: "cnn",
            term: "CNN (Convolutional Neural Network)",
            definition: "A type of neural network especially good at understanding images. It uses filters to detect features like edges, shapes, and textures.",
            category: .neuralNetworks,
            relatedTerms: ["Computer Vision", "Neural Network"],
            example: "CNNs power face filters on Instagram and Snapchat."
        ),
        DictionaryEntry(
            id: "rnn",
            term: "RNN (Recurrent Neural Network)",
            definition: "A neural network designed for sequences — it has a memory that lets it consider previous inputs when processing the current one.",
            category: .neuralNetworks,
            relatedTerms: ["Transformer", "LSTM"],
            example: "RNNs were used for speech recognition before Transformers."
        ),
        DictionaryEntry(
            id: "transformer",
            term: "Transformer",
            definition: "A powerful neural network architecture that processes all parts of the input at once using 'attention.' It's the backbone of modern AI like GPT and Claude.",
            category: .neuralNetworks,
            relatedTerms: ["Attention", "Large Language Model"],
            example: "GPT stands for 'Generative Pre-trained Transformer'."
        ),
        DictionaryEntry(
            id: "attention",
            term: "Attention Mechanism",
            definition: "A technique that lets the AI focus on the most important parts of the input — like how you pay attention to key words in a sentence.",
            category: .neuralNetworks,
            relatedTerms: ["Transformer", "Self-Attention"],
            example: "In 'The cat sat on the mat,' attention helps the AI connect 'cat' with 'sat'."
        ),
        DictionaryEntry(
            id: "gradient_descent",
            term: "Gradient Descent",
            definition: "An optimization method where the AI gradually adjusts its weights to reduce errors — like rolling a ball downhill to find the lowest point.",
            category: .neuralNetworks,
            relatedTerms: ["Backpropagation", "Learning Rate"],
            example: nil
        ),
        DictionaryEntry(
            id: "learning_rate",
            term: "Learning Rate",
            definition: "A number that controls how much the AI adjusts its weights each step. Too big = overshoots. Too small = learns too slowly.",
            category: .neuralNetworks,
            relatedTerms: ["Gradient Descent", "Training"],
            example: nil
        ),
    ]

    // MARK: - NLP
    private static let nlp: [DictionaryEntry] = [
        DictionaryEntry(
            id: "nlp",
            term: "Natural Language Processing (NLP)",
            definition: "The field of AI that focuses on helping computers understand, interpret, and generate human language.",
            category: .nlp,
            relatedTerms: ["Large Language Model", "Tokenization"],
            example: "Autocorrect, translation apps, and voice assistants all use NLP."
        ),
        DictionaryEntry(
            id: "llm",
            term: "Large Language Model (LLM)",
            definition: "A very large AI model trained on massive amounts of text that can understand and generate human-like language.",
            category: .nlp,
            relatedTerms: ["Transformer", "GPT", "Token"],
            example: "GPT-4, Claude, Gemini, and Llama are all LLMs."
        ),
        DictionaryEntry(
            id: "token",
            term: "Token",
            definition: "A piece of text that an AI processes — it could be a word, part of a word, or even a single character. AI reads text as tokens, not letters.",
            category: .nlp,
            relatedTerms: ["Tokenization", "Context Window"],
            example: "The word 'understanding' might be split into 'under' + 'standing'."
        ),
        DictionaryEntry(
            id: "prompt",
            term: "Prompt",
            definition: "The text or instructions you give to an AI to tell it what you want. Better prompts usually give better results.",
            category: .nlp,
            relatedTerms: ["Prompt Engineering", "Completion"],
            example: "'Write a haiku about robots' is a prompt."
        ),
        DictionaryEntry(
            id: "prompt_eng",
            term: "Prompt Engineering",
            definition: "The skill of crafting clear, effective prompts to get the best possible output from an AI model.",
            category: .nlp,
            relatedTerms: ["Prompt", "Few-Shot Learning"],
            example: "Adding 'explain like I'm 10' to your prompt often gives simpler answers."
        ),
        DictionaryEntry(
            id: "context_window",
            term: "Context Window",
            definition: "The maximum amount of text an AI can consider at once. Bigger context windows mean the AI can remember more of the conversation.",
            category: .nlp,
            relatedTerms: ["Token", "LLM"],
            example: "Claude can handle context windows of over 100,000 tokens."
        ),
        DictionaryEntry(
            id: "hallucination",
            term: "Hallucination",
            definition: "When an AI confidently generates information that sounds correct but is actually made up or wrong.",
            category: .nlp,
            relatedTerms: ["LLM", "Accuracy"],
            example: "An AI might invent a fake book title and describe it as if it were real."
        ),
        DictionaryEntry(
            id: "embedding",
            term: "Embedding",
            definition: "A way to represent words, sentences, or images as lists of numbers (vectors) so the AI can understand relationships between them.",
            category: .nlp,
            relatedTerms: ["Vector", "Semantic Search"],
            example: "In an embedding, 'king' and 'queen' would have similar number patterns."
        ),
        DictionaryEntry(
            id: "sentiment",
            term: "Sentiment Analysis",
            definition: "Using AI to detect emotions or opinions in text — figuring out if something is positive, negative, or neutral.",
            category: .nlp,
            relatedTerms: ["NLP", "Classification"],
            example: "A review saying 'This movie was amazing!' would be classified as positive."
        ),
        DictionaryEntry(
            id: "fine_tuning",
            term: "Fine-Tuning",
            definition: "Taking a pre-trained AI model and training it a bit more on specific data so it becomes better at a particular task.",
            category: .nlp,
            relatedTerms: ["Transfer Learning", "Training"],
            example: "Fine-tuning a language model on medical texts to make it better at health Q&A."
        ),
    ]

    // MARK: - Computer Vision
    private static let computerVision: [DictionaryEntry] = [
        DictionaryEntry(
            id: "cv",
            term: "Computer Vision",
            definition: "The field of AI that teaches computers to understand and interpret images and videos — like giving a computer the ability to see.",
            category: .computerVision,
            relatedTerms: ["CNN", "Image Recognition"],
            example: "Face ID on your iPhone uses computer vision."
        ),
        DictionaryEntry(
            id: "image_recognition",
            term: "Image Recognition",
            definition: "An AI's ability to identify objects, people, or scenes in photos and videos.",
            category: .computerVision,
            relatedTerms: ["Computer Vision", "Classification"],
            example: "Google Photos can recognize your friends in pictures."
        ),
        DictionaryEntry(
            id: "object_detection",
            term: "Object Detection",
            definition: "Finding and locating specific objects within an image — not just saying 'there's a car' but drawing a box around it.",
            category: .computerVision,
            relatedTerms: ["Image Recognition", "Bounding Box"],
            example: "Self-driving cars detect pedestrians, signs, and other vehicles."
        ),
        DictionaryEntry(
            id: "ocr",
            term: "OCR (Optical Character Recognition)",
            definition: "AI that reads text from images or scanned documents and converts it into editable digital text.",
            category: .computerVision,
            relatedTerms: ["Computer Vision", "NLP"],
            example: "Scanning a receipt with your phone to extract the total."
        ),
        DictionaryEntry(
            id: "deepfake",
            term: "Deepfake",
            definition: "AI-generated fake videos or images that look extremely realistic, often swapping one person's face onto another's body.",
            category: .computerVision,
            relatedTerms: ["Generative AI", "GAN"],
            example: nil
        ),
    ]

    // MARK: - Generative AI
    private static let generativeAI: [DictionaryEntry] = [
        DictionaryEntry(
            id: "gen_ai",
            term: "Generative AI",
            definition: "AI that can create new content — text, images, music, code, or video — rather than just analyzing existing data.",
            category: .generativeAI,
            relatedTerms: ["LLM", "Diffusion Model", "GAN"],
            example: "DALL·E generates images from text descriptions."
        ),
        DictionaryEntry(
            id: "diffusion",
            term: "Diffusion Model",
            definition: "An AI that generates images by starting with random noise and gradually removing it to create a clear picture, guided by your description.",
            category: .generativeAI,
            relatedTerms: ["Generative AI", "Stable Diffusion"],
            example: "Midjourney and Stable Diffusion use this approach."
        ),
        DictionaryEntry(
            id: "gan",
            term: "GAN (Generative Adversarial Network)",
            definition: "Two AI models that compete: one generates fake content, the other tries to detect fakes. They push each other to improve.",
            category: .generativeAI,
            relatedTerms: ["Generative AI", "Deepfake"],
            example: "GANs can generate photo-realistic faces of people who don't exist."
        ),
        DictionaryEntry(
            id: "temperature",
            term: "Temperature",
            definition: "A setting that controls how creative or random an AI's output is. Low temperature = predictable. High temperature = more creative and surprising.",
            category: .generativeAI,
            relatedTerms: ["LLM", "Sampling"],
            example: "Temperature 0 gives the most likely answer; temperature 1 adds variety."
        ),
        DictionaryEntry(
            id: "few_shot",
            term: "Few-Shot Learning",
            definition: "Giving an AI just a few examples of what you want so it can learn the pattern and apply it — no retraining needed.",
            category: .generativeAI,
            relatedTerms: ["Prompt Engineering", "Zero-Shot"],
            example: "Showing 3 examples of formal emails, then asking the AI to write one."
        ),
        DictionaryEntry(
            id: "rag",
            term: "RAG (Retrieval-Augmented Generation)",
            definition: "A technique where AI first retrieves relevant documents, then uses them to generate more accurate and up-to-date answers.",
            category: .generativeAI,
            relatedTerms: ["LLM", "Embedding"],
            example: "A customer service bot that searches your company's FAQ before answering."
        ),
        DictionaryEntry(
            id: "multimodal",
            term: "Multimodal AI",
            definition: "AI that can understand and work with multiple types of input — text, images, audio, and video — all at once.",
            category: .generativeAI,
            relatedTerms: ["LLM", "Computer Vision"],
            example: "GPT-4 can analyze images and text together."
        ),
    ]

    // MARK: - Ethics
    private static let ethics: [DictionaryEntry] = [
        DictionaryEntry(
            id: "ai_bias",
            term: "AI Bias",
            definition: "When an AI system treats some groups unfairly because of biased data or design choices. It can reinforce existing prejudices.",
            category: .ethics,
            relatedTerms: ["Fairness", "Dataset", "Bias (in ML)"],
            example: "A loan AI denying applications based on zip code could discriminate indirectly."
        ),
        DictionaryEntry(
            id: "fairness",
            term: "Fairness",
            definition: "Making sure AI systems treat all people equitably and don't discriminate based on race, gender, age, or other factors.",
            category: .ethics,
            relatedTerms: ["AI Bias", "Transparency"],
            example: nil
        ),
        DictionaryEntry(
            id: "transparency",
            term: "Transparency",
            definition: "Being open about how an AI works, what data it uses, and how it makes decisions — so people can trust and verify it.",
            category: .ethics,
            relatedTerms: ["Explainability", "Black Box"],
            example: nil
        ),
        DictionaryEntry(
            id: "explainability",
            term: "Explainability (XAI)",
            definition: "The ability to understand and explain why an AI made a specific decision. Important for trust and accountability.",
            category: .ethics,
            relatedTerms: ["Transparency", "Black Box"],
            example: "A doctor needs to know WHY an AI flagged an X-ray, not just that it did."
        ),
        DictionaryEntry(
            id: "black_box",
            term: "Black Box",
            definition: "An AI system whose inner workings are hidden or too complex to understand — you can see the input and output, but not what happens inside.",
            category: .ethics,
            relatedTerms: ["Explainability", "Neural Network"],
            example: nil
        ),
        DictionaryEntry(
            id: "alignment",
            term: "AI Alignment",
            definition: "Making sure an AI's goals and behavior match human values and intentions — a major challenge in AI safety research.",
            category: .ethics,
            relatedTerms: ["AI Safety", "RLHF"],
            example: nil
        ),
        DictionaryEntry(
            id: "rlhf",
            term: "RLHF",
            definition: "Reinforcement Learning from Human Feedback — a training method where humans rate AI outputs to teach the model what good responses look like.",
            category: .ethics,
            relatedTerms: ["Reinforcement Learning", "AI Alignment"],
            example: "ChatGPT was trained with RLHF to give helpful, harmless answers."
        ),
    ]

    // MARK: - Computer Science
    private static let computerScience: [DictionaryEntry] = [
        DictionaryEntry(
            id: "api",
            term: "API (Application Programming Interface)",
            definition: "A set of rules that lets different software programs talk to each other and share data — like a waiter connecting you to the kitchen.",
            category: .computerScience,
            relatedTerms: ["Software", "Integration"],
            example: "Weather apps use APIs to get forecast data from weather services."
        ),
        DictionaryEntry(
            id: "binary",
            term: "Binary",
            definition: "A number system using only 0s and 1s. Computers store and process all information in binary.",
            category: .computerScience,
            relatedTerms: ["Bit", "Data"],
            example: "The number 5 in binary is 101."
        ),
        DictionaryEntry(
            id: "bit_byte",
            term: "Bit & Byte",
            definition: "A bit is the smallest unit of data (0 or 1). A byte is 8 bits — enough to represent one character like the letter 'A'.",
            category: .computerScience,
            relatedTerms: ["Binary", "Data"],
            example: "1 kilobyte = 1,024 bytes. 1 gigabyte = about 1 billion bytes."
        ),
        DictionaryEntry(
            id: "gpu",
            term: "GPU (Graphics Processing Unit)",
            definition: "A special processor designed to handle thousands of calculations at once. Originally for graphics, GPUs are now essential for training AI.",
            category: .computerScience,
            relatedTerms: ["CPU", "Training", "NVIDIA"],
            example: "NVIDIA's GPUs power most AI research labs."
        ),
        DictionaryEntry(
            id: "cpu",
            term: "CPU (Central Processing Unit)",
            definition: "The main processor in a computer — the 'brain' that runs programs and handles general-purpose computing tasks.",
            category: .computerScience,
            relatedTerms: ["GPU", "Computer"],
            example: nil
        ),
        DictionaryEntry(
            id: "cloud",
            term: "Cloud Computing",
            definition: "Using powerful computers over the internet instead of on your own device. AI models often run in the cloud because they need huge computing power.",
            category: .computerScience,
            relatedTerms: ["GPU", "Server"],
            example: "When you use ChatGPT, the AI runs on cloud servers, not your phone."
        ),
        DictionaryEntry(
            id: "open_source",
            term: "Open Source",
            definition: "Software whose code is publicly available for anyone to use, modify, and share. Many AI tools and models are open source.",
            category: .computerScience,
            relatedTerms: ["Software", "Community"],
            example: "Meta's Llama models are open source."
        ),
        DictionaryEntry(
            id: "data_structure",
            term: "Data Structure",
            definition: "A way of organizing and storing data so it can be accessed and modified efficiently. Common examples include arrays, lists, and trees.",
            category: .computerScience,
            relatedTerms: ["Algorithm", "Array"],
            example: "A playlist is like an array — an ordered list of songs."
        ),
        DictionaryEntry(
            id: "boolean",
            term: "Boolean",
            definition: "A data type with only two possible values: true or false. Named after mathematician George Boole.",
            category: .computerScience,
            relatedTerms: ["Binary", "Logic"],
            example: "'Is it raining?' has a boolean answer: true or false."
        ),
        DictionaryEntry(
            id: "recursion",
            term: "Recursion",
            definition: "When a function calls itself to solve a smaller version of the same problem, like a set of Russian nesting dolls.",
            category: .computerScience,
            relatedTerms: ["Algorithm", "Function"],
            example: "Calculating 5! = 5 × 4! = 5 × 4 × 3! ... until you reach 1."
        ),
        DictionaryEntry(
            id: "latency",
            term: "Latency",
            definition: "The delay between making a request and getting a response. Lower latency means faster results.",
            category: .computerScience,
            relatedTerms: ["Performance", "Cloud Computing"],
            example: "The time between pressing send on a message and it being delivered."
        ),
        DictionaryEntry(
            id: "parallel_computing",
            term: "Parallel Computing",
            definition: "Running many calculations at the same time instead of one after another. Essential for training large AI models quickly.",
            category: .computerScience,
            relatedTerms: ["GPU", "Cloud Computing"],
            example: "A GPU can run thousands of operations in parallel."
        ),
    ]

    // MARK: - Math & Stats
    private static let math: [DictionaryEntry] = [
        DictionaryEntry(
            id: "vector",
            term: "Vector",
            definition: "An ordered list of numbers that represents a direction and magnitude. In AI, vectors represent data points, words, or features as lists of numbers.",
            category: .math,
            relatedTerms: ["Matrix", "Embedding", "Dimension"],
            example: "A 2D vector [3, 4] points 3 units right and 4 units up."
        ),
        DictionaryEntry(
            id: "matrix",
            term: "Matrix",
            definition: "A grid of numbers arranged in rows and columns. Neural networks use matrices to process data — multiplying matrices is the core computation in AI.",
            category: .math,
            relatedTerms: ["Vector", "Tensor", "Linear Algebra"],
            example: "A 3×3 matrix has 3 rows and 3 columns = 9 numbers total."
        ),
        DictionaryEntry(
            id: "tensor",
            term: "Tensor",
            definition: "A multi-dimensional array of numbers — think of it as a generalization of vectors (1D) and matrices (2D) to any number of dimensions.",
            category: .math,
            relatedTerms: ["Vector", "Matrix", "TensorFlow"],
            example: "A color image is a 3D tensor: height × width × 3 color channels."
        ),
        DictionaryEntry(
            id: "linear_algebra",
            term: "Linear Algebra",
            definition: "The branch of math dealing with vectors, matrices, and their operations. It's the mathematical foundation of almost all AI and machine learning.",
            category: .math,
            relatedTerms: ["Vector", "Matrix", "Tensor"],
            example: nil
        ),
        DictionaryEntry(
            id: "probability",
            term: "Probability",
            definition: "A number between 0 and 1 that represents how likely something is to happen. AI uses probability to make predictions under uncertainty.",
            category: .math,
            relatedTerms: ["Statistics", "Distribution"],
            example: "A coin flip has a probability of 0.5 (50%) for heads."
        ),
        DictionaryEntry(
            id: "statistics",
            term: "Statistics",
            definition: "The science of collecting, analyzing, and interpreting data. Statistics helps AI understand patterns and make predictions from data.",
            category: .math,
            relatedTerms: ["Probability", "Mean", "Standard Deviation"],
            example: nil
        ),
        DictionaryEntry(
            id: "mean",
            term: "Mean (Average)",
            definition: "The sum of all values divided by the count. It gives you the 'center' of a dataset.",
            category: .math,
            relatedTerms: ["Median", "Statistics"],
            example: "The mean of [2, 4, 6] is (2+4+6)/3 = 4."
        ),
        DictionaryEntry(
            id: "standard_dev",
            term: "Standard Deviation",
            definition: "A measure of how spread out numbers are from the mean. Low = tightly clustered. High = widely spread.",
            category: .math,
            relatedTerms: ["Mean", "Variance"],
            example: "Test scores of [88, 90, 92] have low standard deviation (close together)."
        ),
        DictionaryEntry(
            id: "dimension",
            term: "Dimension",
            definition: "The number of values in a vector, or the number of features in a dataset. AI often works in hundreds or thousands of dimensions.",
            category: .math,
            relatedTerms: ["Vector", "Feature"],
            example: "A point on a map has 2 dimensions (latitude, longitude)."
        ),
        DictionaryEntry(
            id: "dot_product",
            term: "Dot Product",
            definition: "Multiplying matching numbers in two vectors and adding them up. Used everywhere in AI — especially in attention mechanisms.",
            category: .math,
            relatedTerms: ["Vector", "Matrix", "Attention Mechanism"],
            example: "[1,2,3] · [4,5,6] = 1×4 + 2×5 + 3×6 = 32"
        ),
        DictionaryEntry(
            id: "normalization",
            term: "Normalization",
            definition: "Scaling numbers to a standard range (like 0 to 1) so that different features are comparable and the AI can learn more effectively.",
            category: .math,
            relatedTerms: ["Feature", "Preprocessing"],
            example: "Converting test scores from 0–100 and salaries from 0–100,000 both to 0–1."
        ),
        DictionaryEntry(
            id: "loss_function",
            term: "Loss Function",
            definition: "A math formula that measures how wrong the AI's predictions are. Training tries to minimize this number — lower loss means better predictions.",
            category: .math,
            relatedTerms: ["Gradient Descent", "Training"],
            example: nil
        ),
        DictionaryEntry(
            id: "softmax",
            term: "Softmax",
            definition: "A math function that turns a list of numbers into probabilities that add up to 1. Used when AI needs to pick the most likely option.",
            category: .math,
            relatedTerms: ["Probability", "Classification"],
            example: "Scores [2.0, 1.0, 0.1] → probabilities [0.7, 0.2, 0.1]."
        ),
        DictionaryEntry(
            id: "cosine_sim",
            term: "Cosine Similarity",
            definition: "A measure of how similar two vectors are by comparing their direction, ignoring their length. Used to find similar words or documents in AI.",
            category: .math,
            relatedTerms: ["Vector", "Embedding", "Dot Product"],
            example: "Two articles about dogs would have high cosine similarity in their embeddings."
        ),
    ]
}
