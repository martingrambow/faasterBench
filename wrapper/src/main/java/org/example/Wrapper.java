package org.example;
import org.apache.commons.io.FileUtils;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
                
                addFunction(cloudFunction1,"function1", "js", 1);
                addFunction(cloudFunction2,"function2", "js",2);
                break;
            case("py") :
                addFunction(cloudFunction1,"function1", "py",1);
                addFunction(cloudFunction2,"function2", "py",2);
                break;
            default :
                break;
        }
        //TODO


        String fileEnding = "";

        System.out.println("Finished building wrapper function");


    }
    public boolean addFunction(String cloudFunction, String templateFunction, String lang, Integer split) throws IOException {
        switch(lang){
            case "js":
                //externalTime
                var cloudFunction_mod = cloudFunction.substring(0,cloudFunction.length()-3) +"_mod.js";
                Path path = Paths.get(cloudFunction);
                Path path2 = Paths.get(cloudFunction_mod);
                Charset charset = StandardCharsets.UTF_8;
                String content = new String(Files.readAllBytes(path), charset);
                int count = 0;



                //check if splitting functionality was used
                String splitVariablesGoogle = "";
                String splitVariablesAmazon = "";
                String splitVarDef = "";
                String splitVariable = "";
                String splitVariables1 = "";
                String splitVariables2 = "";
                while(content.contains("//split")){
                    Pattern pattern = Pattern.compile("//split (.*)");
                    Matcher matcher = pattern.matcher(content);
                        if (matcher.find())
                        {
                            splitVariable = matcher.group(0);
                            splitVariable = splitVariable.substring(8);
                            splitVariables1 += splitVariable +"1, ";
                            splitVariables2 += splitVariable +"2, ";
                            String replacerVariable = splitVariable+Integer.toString(split);
                            content = content.replaceAll(splitVariable, replacerVariable);
                            System.out.println("Replaced "+splitVariable+ " with split option "+ replacerVariable);
                            splitVarDef += "var "+ replacerVariable+";\n    ";
                            splitVariablesGoogle += replacerVariable+" = escapeHtml(req.query."+replacerVariable+" || req.body."+replacerVariable+");\n    ";
                            splitVariablesAmazon += replacerVariable+" = event.queryStringParameters."+replacerVariable+";\n        ";
                        }
                    content = content.replaceFirst("//split", "//var");
                }
                splitVariables1 = splitVariables1.substring(0, splitVariables1.length()-2);
                splitVariables2 = splitVariables2.substring(0, splitVariables2.length()-2);
                

                //check if external call functionality was used
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
                
                //split variables within google
                path = Paths.get("output/google/index.js");
                charset = StandardCharsets.UTF_8;
                content = new String(Files.readAllBytes(path), charset);
                
                String replacerText = "var experimentID = process.env.EXPERIMENTID;";
                content = content.replaceAll(replacerText,splitVariablesGoogle+replacerText);
                
                replacerText = "//comment for split to replace";
                content = content.replaceAll("//comment for split to replace", splitVarDef+replacerText);
                if(splitVarDef.length() > 0){
                    content = content.replaceAll("function1\\(\\);", "function1("+splitVariables1+");");
                    content = content.replaceAll("function2\\(\\);", "function2("+splitVariables2+");");
                    content = content.replaceAll("function1\\(\\)", "function1("+splitVariables1+")");
                    content = content.replaceAll("function2\\(\\)", "function2("+splitVariables2+")");
                }
                Files.write(path, content.getBytes(charset));


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

                //split var in AWS
                path = Paths.get("output/aws/index.js");
                charset = StandardCharsets.UTF_8;
                content = new String(Files.readAllBytes(path), charset);
                replacerText = "mode = event.queryStringParameters.mode;";
                content = content.replaceAll(replacerText,splitVariablesAmazon+replacerText);
                replacerText = "//comment for split to replace";
                content = content.replaceAll(replacerText, splitVarDef+replacerText);
                if(splitVarDef.length() > 0){
                    content = content.replaceAll("function1\\(\\);", "function1("+splitVariables1+");");
                    content = content.replaceAll("function2\\(\\);", "function2("+splitVariables2+");");
                    content = content.replaceAll("function1\\(\\)", "function1("+splitVariables1+")");
                    content = content.replaceAll("function2\\(\\)", "function2("+splitVariables2+")");
                }
                Files.write(path, content.getBytes(charset));


                
                break;
            case "py":
                break;
            default:
                break;
        }
        return true;
    }
}
