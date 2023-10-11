package org.example;
import org.apache.commons.io.FileUtils;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

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
                File inputGoogle = new File("templates/google/template.js");
                File inputAWS = new File("templates/aws/template.js");
                File outputGoogle = new File("output/google/index.js");
                File outputAWS = new File("output/aws/index.js");
                File inputGoogle1 = new File("templates/google/package.json");
                File inputAWS1 = new File("templates/aws/package.json");
                File outputGoogle1 = new File("output/google/package.json");
                File outputAWS1 = new File("output/aws/package.json");
                try {
                    FileUtils.forceDelete(outputGoogle1);
                }catch(FileNotFoundException e){

                }
                try {
                    FileUtils.forceDelete(outputAWS1);
                }catch(FileNotFoundException e){

                }
                try {
                    FileUtils.forceDelete(outputGoogle);
                }catch(FileNotFoundException e){

                }
                try {
                    FileUtils.forceDelete(outputAWS);
                }catch(FileNotFoundException e){

                }
                FileUtils.copyFile(inputGoogle,outputGoogle);
                FileUtils.copyFile(inputAWS,outputAWS);
                FileUtils.copyFile(inputGoogle1,outputGoogle1);
                FileUtils.copyFile(inputAWS1,outputAWS1);
                
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
                //externalTime
                var cloudFunction_mod = cloudFunction.substring(0,cloudFunction.length()-3) +"_mod.js";
                Path path = Paths.get(cloudFunction);
                Path path2 = Paths.get(cloudFunction_mod);
                Charset charset = StandardCharsets.UTF_8;
                String content = new String(Files.readAllBytes(path), charset);
                int count = 0;
                while(content.contains("//extstart")){
                    content = content.replaceFirst("//extstart","extStart"+Integer.toString(count)+" = Date.now();");
                    count++;
                }
                count = 0;
                while(content.contains("//extstop")){
                    content = content.replaceFirst("//extstop","extStop"+Integer.toString(count)+" = Date.now(); extTime["+Integer.toString(count)+"] = extStop"+Integer.toString(count)+" - extStart"+Integer.toString(count)+";");
                    count++;
                }
                content = content.replaceAll(".*return.*;(\r?\n|\r)?","return extTime;");
                Files.write(path2, content.getBytes(charset));
                File mFile = new File(cloudFunction_mod);
                FileInputStream fis = new FileInputStream(mFile);
                BufferedReader br = new BufferedReader(new InputStreamReader(fis));
                String result = "";
                String line = "";
                while( (line = br.readLine()) != null){
                result = result + line + "\n"; 
                }
                String extVariables = "const extTime = [];\n";
                for(int i = 0; i < count; i++){
                    extVariables += "var extStart"+Integer.toString(i)+" = 0;\n" + "var extStop"+Integer.toString(i)+" = 0;\n";
                }
                result = extVariables + result;
                var cloudFunction_mod2 = cloudFunction.substring(0,cloudFunction.length()-3) +"_mod2.js";
                FileOutputStream fos = new FileOutputStream(cloudFunction_mod2);
                fos.write(result.getBytes());
                fos.flush();
                //Google
                File file = new File("output/google/index.js");
                BufferedWriter writer = new BufferedWriter(new FileWriter(file, true));
                writer.append("\r\nfunction "+templateFunction+"() {");
                BufferedReader reader = new BufferedReader(new FileReader(cloudFunction_mod2));
                String currentLine = reader.readLine();
                while(currentLine != null){
                    writer.newLine();
                    writer.append("   "+currentLine);
                    currentLine = reader.readLine();
                }
                reader.close();
                writer.append("\r\n}");
                writer.close();
                
                //AWS
                file= new File("output/aws/index.js");
                writer = new BufferedWriter(new FileWriter(file, true));
                writer.append("\r\nfunction "+templateFunction+"() {");
                reader = new BufferedReader(new FileReader(cloudFunction_mod2));
                currentLine = reader.readLine();
                while(currentLine != null){
                    writer.newLine();
                    writer.append("   "+currentLine);
                    currentLine = reader.readLine();
                }
                reader.close();
                writer.append("\r\n}");
                writer.close();
                File delFile = new File(cloudFunction_mod);
                delFile.delete();
                delFile = new File(cloudFunction_mod2);
                delFile.delete();
                break;
            case "py":
                break;
            default:
                break;
        }
        return true;
    }
}
