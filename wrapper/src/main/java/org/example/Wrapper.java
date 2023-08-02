package org.example;
import org.apache.commons.io.FileUtils;

import java.io.*;
import java.nio.charset.StandardCharsets;

public class Wrapper {

    public void buildWrapper(String cloudFunction1, String cloudFunction2) throws IOException {
        System.out.println("buildWrapper starting..");
        System.out.println("Received "+ cloudFunction1 + " and "+ cloudFunction2);
        String functionType = "";
        if(cloudFunction1.endsWith(".py")){
            System.out.println("Python detected");
            functionType = "py";
        }else {
            System.out.println("Javascript detected");
            functionType = "js";
        }
        switch(functionType){
            case("js") :
                //create output file
                //File input = new File("templates/template.js");
                //File output = new File("output/index.js");
                //File input1 = new File("templates/package.json");
                //File output1 = new File("output/package.json");
                File input = new File("wrapper/templates/template.js");
                File output = new File("wrapper/output/index.js");
                File input1 = new File("wrapper/templates/package.json");
                File output1 = new File("wrapper/output/package.json");
                try {
                    FileUtils.forceDelete(output);
                }catch(FileNotFoundException e){

                }
                try {
                    FileUtils.forceDelete(output1);
                }catch(FileNotFoundException e){

                }
                FileUtils.copyFile(input,output);
                FileUtils.copyFile(input1,output1);
                addFunction(cloudFunction1,"function1", "js");
                addFunction(cloudFunction2,"function2", "js");
                break;
            case("py") :
                addFunction(cloudFunction1,"function1", "py");
                addFunction(cloudFunction2,"function2", "py");
                break;
            default :
                break;
        }
        //TODO


        String fileEnding = "";

        System.out.println("Finished building wrapper function");


    }
    public boolean addFunction(String cloudFunction, String templateFunction, String lang) throws IOException {
        switch(lang){
            case "js":
                File file = new File("wrapper/output/index.js");
                BufferedWriter writer = new BufferedWriter(new FileWriter(file, true));
                writer.append("\r\nfunction "+templateFunction+"() {");
                BufferedReader reader = new BufferedReader(new FileReader(cloudFunction));
                String currentLine = reader.readLine();
                while(currentLine != null){
                    writer.newLine();
                    writer.append("   "+currentLine);
                    currentLine = reader.readLine();
                }
                reader.close();
                writer.append("\r\n}");
                writer.close();
                break;
            case "py":
                break;
            default:
                break;
        }
        return true;
    }
}
