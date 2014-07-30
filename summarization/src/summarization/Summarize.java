package summarization;

import java.awt.List;
import java.io.*;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Scanner;
import java.util.Set;

import opennlp.tools.sentdetect.SentenceDetectorME;
import opennlp.tools.sentdetect.SentenceModel;

public class Summarize {

	private static Process p;
	public static boolean ASC = true;
	public static boolean DESC = false;
	private static Map<String, Float> finalunordered;

	public static void main(String[] args) throws IOException,
			InterruptedException {

		float percentage = Float.parseFloat(args[0]);
		if (args.length == 1 && percentage <= 1 && percentage >= 0) {

		} else {
			System.out.println("Invalid arguments");
			return;
		}
		File f = new File(System.getProperty("java.class.path"));
		File dir = f.getAbsoluteFile().getParentFile();
		String path = dir.toString();

		String everything = "";
		String everythingclean = "";
		String STOP_WORD = "";
		
		
		BufferedReader stopwordi = new BufferedReader(new FileReader(path
				+ "/StopWord33.txt"));
		BufferedReader br = new BufferedReader(new FileReader(path
				+ "/pairWord.txt"));
		PrintWriter out = new PrintWriter(new FileWriter(path
				+ "/pairSimValue.txt"));
		PrintWriter outin = new PrintWriter(new FileWriter(path + "/in.txt"));

		// read stopwords from input file

				try {
					String line = stopwordi.readLine();

					while (line != null) {
						if (line.isEmpty() || line.trim().equals("")
								|| line.trim().equals("\n"))
							continue;
						STOP_WORD+=line.trim()+" ";
					}
				} finally {
					stopwordi.close();
				}

				// clean it from stop words
		
		
		// // The variable everything contains all the text, everythingclean has all text without stopwords
		try {
			BufferedReader bri = new BufferedReader(new FileReader(path
					+ "/initialinput.txt"));
			StringBuilder sb = new StringBuilder();
			String line = bri.readLine();

			while (line != null) {
				if (line.isEmpty() || line.trim().equals("")
						|| line.trim().equals("\n"))
					continue;
				sb.append(line);
				line = line.toLowerCase();
				Scanner s = new Scanner(line);

				String temp1 = null;
				while (s.hasNext()) {
					temp1 = s.next();
					if (STOP_WORD.contains(temp1))
						continue;

					everythingclean = everythingclean + temp1.toLowerCase() + " ";
				}
				everything = sb.toString();
				s.close();
			}
			bri.close();
			
		} finally {

		}

		

		// Make the
		outin.print(everything);
		outin.close();

		String input = "";

		//create pairWord.txt and store everythingclean in cleanText.txt
		
		
		// get Perl to extract the pairs
		p = Runtime.getRuntime().exec(path + "/run1.sh");
		p.waitFor();

		// Connect to GTM engine and compute similarity

		int count = 0;

		while ((input = br.readLine()) != null) {
			count++;
			DalServerCon conn = new DalServerCon(2222, "localhost");
			conn.connect();
			conn.getOs().println("wordword");
			conn.getOs().println(input);
			conn.getOs().println("\1done");
			conn.getOs().flush();

			StringBuilder pairs = new StringBuilder();
			StringBuilder similarity = new StringBuilder();

			String line;
			while ((line = conn.getIs().readLine()) != null) {
				if ((!line.isEmpty()) && line.charAt(0) == '\1') {
					break;
				} else {
					String[] pairSim = line.split("\1");
					pairs.append(pairSim[0]);
					similarity.append(pairSim[1]);
				}// else
			}// while
			out.print(similarity.toString() + "\n");
			conn.close();
		}
		br.close();
		out.close();
		// formulate the command and insert it to the sh file;
		String command = "perl long_text_to_sorted_words.pl cleanText.txt pairWord.txt pairSimValue.txt "/*
																										 * +
																										 * Integer
																										 * .
																										 * toString
																										 * (
																										 * count
																										 * )
																										 */
				+ " out.txt";
		PrintWriter shfile = new PrintWriter(new FileWriter(path + "/run2.sh"));
		shfile.print(command);
		shfile.close();

		p = Runtime.getRuntime().exec(path + "/run2.sh");
		p.waitFor();
		// read out.txt to an array
		BufferedReader bro = new BufferedReader(new FileReader(path
				+ "/out.txt"));
		HashMap<String, Float> hm = new HashMap<String, Float>();
		HashMap<String, Float> unsortedhm = new HashMap<String, Float>();

		while ((input = bro.readLine()) != null) {
			if (input.matches("\\w*"))
				continue;
			String[] array = input.split("\\s+");
			hm.put(array[0], Float.parseFloat(array[1]));
		}
		bro.close();
		// split everything based on (.)

		// String[] sentences = everything.split("\\.");

		InputStream is = new FileInputStream("en-sent.bin");
		SentenceModel model = new SentenceModel(is);
		SentenceDetectorME sdetector = new SentenceDetectorME(model);
		// System.out.println(token1);

		String sentences[] = sdetector.sentDetect(everything);
		is.close();

		// for each sentence, compute avg and std
		for (int i = 0; i < sentences.length; i++) {
			String[] words = sentences[i].split("\\s+");
			float sum = 0;
			int count1 = 0;
			// mean
			for (int j = 0; j < words.length; j++) {
				// if the word exist in the hm, use it to compute std and avg
				Object value = hm.get(words[j]);
				if (value != null) {
					sum += (Float) value;
					count1++;
				}

			}

			float average = sum / (float) count1;

			// Variance
			float temp = 0;
			for (int j = 0; j < words.length; j++) {
				// if the word exist in the hm, use it to compute std and avg
				Object value = hm.get(words[j]);
				if (value != null) {
					temp += ((average - (Float) value) * (average - (Float) value));
				}
			}

			float std = (float) Math.sqrt((temp / (float) count1));
			// System.out.println("STD" + std);

			unsortedhm.put(sentences[i], (average + std));

		}
		//

		Map<String, Float> sortedMapAsc = sortByComparator(unsortedhm, DESC);

		int wcount = countWords(everything);
		float wordstoremain = percentage * wcount;

		int totallength = 0;
		finalunordered = null;
		String unordered = null;
		for (Entry<String, Float> entry : sortedMapAsc.entrySet()) {
			int entryLength = entry.getKey().split("\\s+").length - 1;
			// System.out.println(entryLength);
			totallength += entryLength;

			unordered += entry.getKey() + " ";

			if (totallength >= wordstoremain)
				break;

		}

		// String[] sentence = everything.split("\\.");

		// InputStream is = new FileInputStream("en-sent.bin");
		// SentenceModel model = new SentenceModel(is);
		// SentenceDetectorME sdetector = new SentenceDetectorME(model);
		// System.out.println(token1);

		String sentence[] = sdetector.sentDetect(everything);
		is.close();

		String finalSummary = "";

		for (int i = 0; i < sentence.length; i++) {
			if (unordered.contains(sentence[i]))
				finalSummary += sentence[i] + ".";

		}
		PrintWriter out2 = new PrintWriter(new FileWriter(path
				+ "/finaloutput.txt"));
		System.out.println(finalSummary);
		out2.print(finalSummary);
		out2.close();

	}

	private static Map<String, Float> sortByComparator(
			Map<String, Float> unsortMap, final boolean order) {

		LinkedList<Entry<String, Float>> list = new LinkedList<Entry<String, Float>>(
				unsortMap.entrySet());

		// Sorting the list based on values
		Collections.sort(list, new Comparator<Entry<String, Float>>() {
			public int compare(Entry<String, Float> o1, Entry<String, Float> o2) {
				if (order) {
					return o1.getValue().compareTo(o2.getValue());
				} else {
					return o2.getValue().compareTo(o1.getValue());

				}
			}
		});

		// Maintaining insertion order with the help of LinkedList
		Map<String, Float> sortedMap = new LinkedHashMap<String, Float>();
		for (Entry<String, Float> entry : list) {
			sortedMap.put(entry.getKey(), entry.getValue());
		}

		return sortedMap;
	}

	public static void printMap(Map<String, Float> map) {
		for (Entry<String, Float> entry : map.entrySet()) {
			System.out.println("Key : " + entry.getKey() + " Value : "
					+ entry.getValue());
		}
	}

	public static int countWords(String str) {
		int count = 1;
		for (int i = 0; i <= str.length() - 1; i++) {
			if (str.charAt(i) == ' ' && str.charAt(i + 1) != ' ') {
				count++;
			}
		}
		return count;
	}
}
