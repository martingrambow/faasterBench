package org.example;
import org.apache.commons.io.FileUtils;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.PublicKey;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class Wrapper {

    public void buildWrapper(String cloudFunction1, String cloudFunction2, String cloudFunction3, Boolean aSyncReq) throws IOException {
        System.out.println("buildWrapper starting..");
        System.out.println("Received "+ cloudFunction1 + " and "+ cloudFunction2);

        //Define input files
        File inputGoogle;
        File inputAWS;
        File inputAzure = new File ("templates/azure/template.js");
        File outputGoogle;
        File outputAWS;
        File outputAzure;
        File outputGoogleFolder;
        File outputAWSFolder;
        File outputAzureFolder;

        //if async function is needed
        if(aSyncReq){
            inputGoogle = new File("templates/google/template_async.js");
            inputAWS = new File("templates/aws/template_async.js");
        }else{
            inputGoogle = new File("templates/google/template.js");
            inputAWS = new File("templates/aws/template.js");
        }
        //check what function type is being used
        if(cloudFunction1.contains("cpu")){
            outputGoogle = new File("output/cpu/google/index.js");
            outputAWS = new File("output/cpu/aws/index.js");
            outputAzure = new File("output/cpu/azure/index.js");
            outputAWSFolder = new File("output/cpu/aws");
            outputAzureFolder = new File("output/cpu/azure");
            outputGoogleFolder = new File("output/cpu/google");
        }else if (cloudFunction1.contains("mem")){
            outputGoogle = new File("output/mem/google/index.js");
            outputAWS = new File("output/mem/aws/index.js");
            outputAzure = new File("output/mem/azure/index.js");
            outputAWSFolder = new File("output/mem/aws");
            outputAzureFolder = new File("output/mem/azure");
            outputGoogleFolder = new File("output/mem/google");
        }
        else if (cloudFunction1.contains("network")){
            outputGoogle = new File("output/network/google/index.js");
            outputAWS = new File("output/network/aws/index.js");
            outputAzure = new File("output/network/azure/index.js");
            outputAWSFolder = new File("output/network/aws");
            outputAzureFolder = new File("output/network/azure");
            outputGoogleFolder = new File("output/network/google");
        }
        else if (cloudFunction1.contains("io")){
            outputGoogle = new File("output/io/google/index.js");
            outputAWS = new File("output/io/aws/index.js");
            outputAzure = new File("output/io/azure/index.js");
            outputAWSFolder = new File("output/io/aws");
            outputAzureFolder = new File("output/io/azure");
            outputGoogleFolder = new File("output/io/google");
        }
        else {
            outputGoogle = new File("output/default/google/index.js");
            outputAWS = new File("output/default/aws/index.js");
            outputAzure = new File("output/default/azure/index.js");
            outputAWSFolder = new File("output/default/aws");
            outputAzureFolder = new File("output/default/azure");
            outputGoogleFolder = new File("output/default/google");
        }

        //remove old files in output folder
        for(File file : outputGoogleFolder.listFiles()){
            if(!file.isDirectory()){
                file.delete();
            }
        }
        for(File file : outputAWSFolder.listFiles()){
            if(!file.isDirectory()){
                file.delete();
            }
        }
        for(File file : outputAzureFolder.listFiles()){
            if(!file.isDirectory()){
                file.delete();
            }
        }
        try {
            FileUtils.forceDelete(outputGoogle);
        }catch(FileNotFoundException e){

        }
        try {
            FileUtils.forceDelete(outputAWS);
        }catch(FileNotFoundException e){

        }
        try {
            FileUtils.forceDelete(outputAzure);
        }catch(FileNotFoundException e){

        }

        //copy template files to output folder to update them
        FileUtils.copyFile(inputGoogle,outputGoogle);
        FileUtils.copyFile(inputAWS,outputAWS);
        FileUtils.copyFile(inputAzure,outputAzure);
        var experimentFolder = cloudFunction1.substring(0, cloudFunction1.lastIndexOf("/"));

        //if input functions differ from provider to provider
        if(cloudFunction1.endsWith("google")){
            System.out.println("Advanced configuration");
            var cloudFunction1Google = cloudFunction1 + "/dir1/index.js";
            var cloudFunction2Google = cloudFunction1 + "/dir2/index.js";
            var cloudFunction1AWS = cloudFunction2 + "/dir2/index.js";
            var cloudFunction2AWS = cloudFunction2 + "/dir2/index.js";
            var cloudFunction1Azure = cloudFunction3 + "/dir1/index.js";
            var cloudFunction2Azure = cloudFunction3 + "/dir2/index.js";

            addGoogleFunction(cloudFunction1Google,"function1",outputGoogleFolder.toString(), "js", 1, aSyncReq);
            addGoogleFunction(cloudFunction2Google,"function2",outputGoogleFolder.toString(), "js",2, aSyncReq);
            addAWSFunction(cloudFunction1AWS,"function1",outputAWSFolder.toString(), "js", 1, aSyncReq);
            addAWSFunction(cloudFunction2AWS,"function2", outputAWSFolder.toString(),"js",2, aSyncReq);
            addAzureFunction(cloudFunction1Azure,"function1",outputAzureFolder.toString(), "js", 1, aSyncReq);
            addAzureFunction(cloudFunction2Azure,"function2",outputAzureFolder.toString(), "js",2, aSyncReq);
            System.out.println("Finished building wrapper function");
        }else{
            //if input functions are the same
            addGoogleFunction(cloudFunction1,"function1",outputGoogleFolder.toString(), "js", 1, aSyncReq);
            addGoogleFunction(cloudFunction2,"function2",outputGoogleFolder.toString(), "js",2, aSyncReq);
            addAWSFunction(cloudFunction1,"function1",outputAWSFolder.toString(), "js", 1, aSyncReq);
            addAWSFunction(cloudFunction2,"function2",outputAWSFolder.toString(), "js",2, aSyncReq);
            addAzureFunction(cloudFunction1,"function1",outputAzureFolder.toString(), "js", 1, aSyncReq);
            addAzureFunction(cloudFunction2,"function2",outputAzureFolder.toString(), "js",2, aSyncReq);
            System.out.println("Finished building wrapper function");
            experimentFolder = experimentFolder.substring(0,experimentFolder.lastIndexOf("/"));
        }

        //move all files from input folder to output folder
        System.out.println(experimentFolder);
        File[] fileList = new File(experimentFolder).listFiles();
        for( var file : fileList){
            if(!file.toString().endsWith("aws") && !file.toString().endsWith("google") && !file.toString().endsWith("azure") && !file.toString().endsWith("dir1") && !file.toString().endsWith("dir2")){
                System.out.println(file);
                String fileName = file.toString().substring(file.toString().lastIndexOf("/"));
                File destFile1 = new File(outputAWSFolder.toString()+fileName);
                File destFile2 = new File(outputGoogleFolder.toString()+fileName);
                File destFile3 = new File(outputAzureFolder.toString()+fileName);
                FileUtils.copyFile(file,destFile1);
                FileUtils.copyFile(file,destFile2);
                FileUtils.copyFile(file,destFile3);
                
            }
            
        }
        //Backwards compatibility
        File destGoogle = new File("output/google");
        File destAWS = new File("output/aws/");
        FileUtils.copyDirectory(outputGoogleFolder, destGoogle);
        FileUtils.copyDirectory(outputAWSFolder, destAWS);
    }


    //Google Function
    public boolean addGoogleFunction(String cloudFunction, String templateFunction, String outputFolder, String lang, Integer split, Boolean aSyncReq) throws IOException {
        //externalTime
        var cloudFunction_mod = cloudFunction.substring(0,cloudFunction.length()-3) +"_mod.js";
        var cloudFunction_mod2 = cloudFunction.substring(0,cloudFunction.length()-3) +"_mod2.js";
        Path defaultPath = Paths.get(".");
        Path path = Paths.get(defaultPath.toString(),cloudFunction);
        Path path1 = Paths.get(defaultPath.toString(),cloudFunction_mod);
        Path path2 = Paths.get(defaultPath.toString(),cloudFunction_mod2);
        Charset charset = StandardCharsets.UTF_8;
        String content = new String(Files.readAllBytes(path), charset);
        int count = 0;

        //check if splitting functionality was used
        String variablesGoogle = "";

        String varDef = "";
        String splitVariable = "";
        String variables1 = "";
        String variables2 = "";
        String entryVariable = "";
        String functionName = "";
        while(content.contains("//entry")){
            Pattern pattern = Pattern.compile("//entry (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    entryVariable = matcher.group(0);
                    entryVariable = entryVariable.substring(8);
                    if(split == 1 ){
                        variablesGoogle += entryVariable+" = escapeHtml(req.query."+entryVariable+" || req.body."+entryVariable+");\n    ";
                        varDef += "var "+ entryVariable+";\n    ";
                    }
                    variables1+=entryVariable+", ";
                    variables2+=entryVariable+", ";
                }
            content = content.replaceFirst("//entry", "//var");
        }
        
        //functionName detection (relevant for recursive functions that call themselves, otherwise the old function name would remain)
        while(content.contains("//functionName")){
            Pattern pattern = Pattern.compile("//functionName (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    functionName = matcher.group(0);
                    functionName = entryVariable.substring(15);
                    
                }
            content = content.replaceFirst("//functionName", "//function name ");
        }

        String variables1Split = variables1;
        String variables2Split = variables2;

        while(content.contains("//split")){
            Pattern pattern = Pattern.compile("//split (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    splitVariable = matcher.group(0);
                    splitVariable = splitVariable.substring(8);
                    variables1 += splitVariable+", ";
                    variables2 += splitVariable+", ";
                    variables1Split += splitVariable +"1, ";
                    variables2Split += splitVariable +"2, ";
                    String replacerVariable = splitVariable+Integer.toString(split);
                    //content = content.replaceAll(splitVariable, replacerVariable);
                    //System.out.println("Replaced "+splitVariable+ " with split option "+ replacerVariable);
                    varDef += "var "+ replacerVariable+";\n    ";
                    variablesGoogle += replacerVariable+" = escapeHtml(req.query."+replacerVariable+" || req.body."+replacerVariable+");\n    ";
                }
            content = content.replaceFirst("//split", "//var");
        }

        //check if functionality was used and trim trailing characters
        if(variables1.length() >0){
            variables1 = variables1.substring(0, variables1.length()-2);
            variables2 = variables2.substring(0, variables2.length()-2);
            variables1Split = variables1Split.substring(0, variables1Split.length()-2);
            variables2Split = variables2Split.substring(0, variables2Split.length()-2);
        }
        //define template replacer text to insert our values
        String importVariable;
        String importVariables="";
        String importReplacerText = "const escapeHtml =";

        //shift imports from function to top level
        while(content.contains("import")){
            Pattern pattern = Pattern.compile("import (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    importVariable = matcher.group(0);
                    importVariables=importVariables+importVariable+"\n";
                    System.out.println("Shifted import '"+ matcher.group(0)+ "' from function to top level");
                }
            content = content.replaceFirst(matcher.group(0), "");
        }
        

        //check if external call functionality was used
        while(content.contains("//extstart")){
            content = content.replaceFirst("//extstart","extStart"+Integer.toString(count)+" = Date.now();");
            count++;
        }
        count = 0;
        while(content.contains("//extstop")){
            content = content.replaceFirst("//extstop","extStop"+Integer.toString(count)+" = Date.now();\nextTime.push(extStop"+Integer.toString(count)+" - extStart"+Integer.toString(count)+");");
            count++;
        }

        //content = content.replaceAll(".*return.*;(\r?\n|\r)?","return extTime;");
        Files.write(path1, content.getBytes(charset));
        File mFile = new File(path1.toString());
        FileInputStream fis = new FileInputStream(mFile);
        BufferedReader br = new BufferedReader(new InputStreamReader(fis));
        String result = "";
        String line = "";
        while( (line = br.readLine()) != null){
        result = result + line + "\n"; 
        }
        String extVariables = "var extTime = [];\n";
        for(int i = 0; i < count; i++){
            extVariables += "var extStart"+Integer.toString(i)+";\n" + "var extStop"+Integer.toString(i)+";\n";
        }
        
        
        result = extVariables + result;
        
        FileOutputStream fos = new FileOutputStream(path2.toString());
        fos.write(result.getBytes());
        fos.flush();

        //write files
        File file = new File(outputFolder+"/index.js");
        BufferedWriter writer = new BufferedWriter(new FileWriter(file, true));
        if(aSyncReq){
            writer.append("\r\nasync function "+templateFunction+"() {");
        }else{
            writer.append("\r\nfunction "+templateFunction+"() {");
        }
        
        BufferedReader reader = new BufferedReader(new FileReader(path2.toString()));
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
        path = Paths.get(outputFolder+"/index.js");
        charset = StandardCharsets.UTF_8;
        content = new String(Files.readAllBytes(path), charset);
        
        String replacerText = "var experimentID = process.env.EXPERIMENTID;";
        content = content.replaceAll(replacerText,variablesGoogle+replacerText);
        
        replacerText = "//comment for split to replace";
        content = content.replaceAll("//comment for split to replace", varDef+replacerText);

        if(functionName.length() > 0){
            content = content.replaceAll(functionName, "function"+split.toString());
        }

        if(importVariables.length() > 0){
            content = content.replaceAll(importReplacerText, importVariables+importReplacerText);
        }
        if(varDef.length() > 0 || variables1.length() > 0 || variables2.length() > 0){
            content = content.replaceAll("function1\\(\\);", "function1("+variables1Split+");");
            content = content.replaceAll("function2\\(\\);", "function2("+variables2Split+");");
            content = content.replaceAll("function1\\(\\)", "function1("+variables1+")");
            content = content.replaceAll("function2\\(\\)", "function2("+variables2+")");
        }
        Files.write(path, content.getBytes(charset));
        File delFile = new File(path1.toString());
        delFile.delete();
        delFile = new File(path2.toString());
        delFile.delete();
        return true;
    }

    //AWS function
    public boolean addAWSFunction(String cloudFunction, String templateFunction, String outputFolder, String lang, Integer split, Boolean aSyncReq) throws IOException {
        //define paths and temp function files, which are deleted at the end

        var cloudFunction_mod = cloudFunction.substring(0,cloudFunction.length()-3) +"_mod.js";
        var cloudFunction_mod2 = cloudFunction.substring(0,cloudFunction.length()-3) +"_mod2.js";
        Path defaultPath = Paths.get(".");
        System.out.println(defaultPath);
        Path path = Paths.get(defaultPath.toString(),cloudFunction);
        Path path1 = Paths.get(defaultPath.toString(),cloudFunction_mod);
        Path path2 = Paths.get(defaultPath.toString(),cloudFunction_mod2);
        Charset charset = StandardCharsets.UTF_8;
        String content = new String(Files.readAllBytes(path), charset);
        int count = 0;

        
        String VariablesAmazon = "";
        String varDef = "";
        String splitVariable = "";
        String variables1 = "";
        String variables2 = "";
        String entryVariable = "";
        String functionName = "";

        //check for function entry variables
        while(content.contains("//entry")){
            Pattern pattern = Pattern.compile("//entry (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    entryVariable = matcher.group(0);
                    entryVariable = entryVariable.substring(8);
                    if(split == 1){
                        varDef += "var "+ entryVariable+";\n    ";
                        VariablesAmazon += entryVariable+" = event.queryStringParameters."+entryVariable+";\n        ";
                    }
                    variables1+=entryVariable+", ";
                    variables2+=entryVariable+", ";
                }
            content = content.replaceFirst("//entry", "//var");
        }

        //functionName detection (relevant for recursive functions that call themselves)
        while(content.contains("//functionName")){
            Pattern pattern = Pattern.compile("//functionName (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    functionName = matcher.group(0);
                    functionName = entryVariable.substring(15);
                    
                }
            content = content.replaceFirst("//functionName", "//function name ");
        }

        String variables1Split = variables1;
        String variables2Split = variables2;
        while(content.contains("//split")){
            Pattern pattern = Pattern.compile("//split (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    splitVariable = matcher.group(0);
                    splitVariable = splitVariable.substring(8);
                    variables1 += splitVariable+", ";
                    variables2 += splitVariable+", ";
                    variables1Split += splitVariable +"1, ";
                    variables2Split += splitVariable +"2, ";
                    String replacerVariable = splitVariable+Integer.toString(split);
                    //content = content.replaceAll(splitVariable, replacerVariable);
                    //System.out.println("Replaced "+splitVariable+ " with split option "+ replacerVariable);
                    varDef += "var "+ replacerVariable+";\n    ";
                    VariablesAmazon += replacerVariable+" = event.queryStringParameters."+replacerVariable+";\n        ";
                }
            content = content.replaceFirst("//split", "//var");
        }
        if(variables1.length() >0){
            variables1 = variables1.substring(0, variables1.length()-2);
            variables2 = variables2.substring(0, variables2.length()-2);
            variables1Split = variables1Split.substring(0, variables1Split.length()-2);
            variables2Split = variables2Split.substring(0, variables2Split.length()-2);
        }
        String importVariable;
        String importVariables="";
        String importReplacerText = "const AWS =";
        while(content.contains("import")){
            Pattern pattern = Pattern.compile("import (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    importVariable = matcher.group(0);
                    importVariables=importVariables+importVariable+"\n";
                    System.out.println("Shifted import '"+ matcher.group(0)+ "' from function to top level");
                }
            content = content.replaceFirst(matcher.group(0), "");
        }
        
        

        //check if external call functionality was used
        while(content.contains("//extstart")){
            content = content.replaceFirst("//extstart","extStart"+Integer.toString(count)+" = Date.now();");
            count++;
        }
        count = 0;
        while(content.contains("//extstop")){
            content = content.replaceFirst("//extstop","extStop"+Integer.toString(count)+" = Date.now();\nextTime.push(extStop"+Integer.toString(count)+" - extStart"+Integer.toString(count)+");");
            count++;
        }
        //content = content.replaceAll(".*return.*;(\r?\n|\r)?","return extTime;");
        Files.write(path1, content.getBytes(charset));
        File mFile = new File(path1.toString());
        FileInputStream fis = new FileInputStream(mFile);
        BufferedReader br = new BufferedReader(new InputStreamReader(fis));
        String result = "";
        String line = "";
        while( (line = br.readLine()) != null){
        result = result + line + "\n"; 
        }
        String extVariables = "var extTime = [];\n";
        for(int i = 0; i < count; i++){
            extVariables += "var extStart"+Integer.toString(i)+";\n" + "var extStop"+Integer.toString(i)+";\n";
        }
        
        
        result = extVariables + result;
        
        FileOutputStream fos = new FileOutputStream(path2.toString());
        fos.write(result.getBytes());
        fos.flush();


        //AWS
        File file= new File(outputFolder+"/index.js");
        BufferedWriter writer = new BufferedWriter(new FileWriter(file, true));
        if(aSyncReq){
            writer.append("\r\nasync function "+templateFunction+"() {");
        }else{
            writer.append("\r\nfunction "+templateFunction+"() {");
        }
        
        BufferedReader reader = new BufferedReader(new FileReader(path2.toString()));
        String currentLine = reader.readLine();
        while(currentLine != null){
            writer.newLine();
            writer.append("   "+currentLine);
            currentLine = reader.readLine();
        }
        reader.close();
        writer.append("\r\n}");
        writer.close();
        File delFile = new File(path1.toString());
        delFile.delete();
        delFile = new File(path2.toString());
        delFile.delete();

        //function name replacement 
        if(functionName.length() > 0){
            content = content.replaceAll(functionName, "function"+split.toString());
        }
        //split var in AWS
        path = Paths.get(outputFolder+"/index.js");
        charset = StandardCharsets.UTF_8;
        content = new String(Files.readAllBytes(path), charset);
        String replacerText = "if\\(event.queryStringParameters.mode\\)";
        content = content.replaceAll(replacerText,VariablesAmazon+replacerText);
        replacerText = "//comment for split to replace";
        content = content.replaceAll(replacerText, varDef+replacerText);
        if(importVariables.length() > 0){
            content = content.replaceAll(importReplacerText, importVariables+importReplacerText);
        }
        if(varDef.length() > 0 || variables1.length() > 0 || variables2.length() > 0){
            content = content.replaceAll("function1\\(\\);", "function1("+variables1Split+");");
            content = content.replaceAll("function2\\(\\);", "function2("+variables2Split+");");
            content = content.replaceAll("function1\\(\\)", "function1("+variables1+")");
            content = content.replaceAll("function2\\(\\)", "function2("+variables2+")");
        }
        Files.write(path, content.getBytes(charset));
        return true;
    }

    public boolean addAzureFunction(String cloudFunction, String templateFunction, String outputFolder, String lang, Integer split, Boolean aSyncReq) throws IOException {
        //externalTime
        var cloudFunction_mod = cloudFunction.substring(0,cloudFunction.length()-3) +"_mod.js";
        var cloudFunction_mod2 = cloudFunction.substring(0,cloudFunction.length()-3) +"_mod2.js";
        Path defaultPath = Paths.get(".");
        Path path = Paths.get(defaultPath.toString(),cloudFunction);
        Path path1 = Paths.get(defaultPath.toString(),cloudFunction_mod);
        Path path2 = Paths.get(defaultPath.toString(),cloudFunction_mod2);
        Charset charset = StandardCharsets.UTF_8;
        String content = new String(Files.readAllBytes(path), charset);
        int count = 0;

        //check if splitting functionality was used
        String variablesAzure = "";
        String varDef = "";
        String splitVariable = "";
        String variables1 = "";
        String variables2 = "";
        String entryVariable = "";
        String functionName = "";
        while(content.contains("//entry")){
            Pattern pattern = Pattern.compile("//entry (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    entryVariable = matcher.group(0);
                    entryVariable = entryVariable.substring(8);
                    if(split == 1 ){
                        variablesAzure += entryVariable+" = request.query.get(\""+entryVariable+"\");\n        ";
                        varDef += "var "+ entryVariable+";\n        ";
                    }
                    variables1+=entryVariable+", ";
                    variables2+=entryVariable+", ";
                }
            content = content.replaceFirst("//entry", "//var");
        }
        
        //functionName detection (relevant for recursive functions that call themselves)
        while(content.contains("//functionName")){
            Pattern pattern = Pattern.compile("//functionName (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    functionName = matcher.group(0);
                    functionName = entryVariable.substring(15);
                    
                }
            content = content.replaceFirst("//functionName", "//function name ");
        }
        //since split and entry variables are both added using the same variable, set split variables to entry for now
        String variables1Split = variables1;
        String variables2Split = variables2;
        //check for split variable usage
        while(content.contains("//split")){
            Pattern pattern = Pattern.compile("//split (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    splitVariable = matcher.group(0);
                    splitVariable = splitVariable.substring(8);
                    variables1 += splitVariable+", ";
                    variables2 += splitVariable+", ";
                    variables1Split += splitVariable +"1, ";
                    variables2Split += splitVariable +"2, ";
                    String replacerVariable = splitVariable+Integer.toString(split);
                    //content = content.replaceAll(splitVariable, replacerVariable);
                    //System.out.println("Replaced "+splitVariable+ " with split option "+ replacerVariable);
                    varDef += "var "+ replacerVariable+";\n        ";
                    variablesAzure += replacerVariable+" = request.query.get(\""+replacerVariable+"\");\n        ";
                    System.out.println(variablesAzure);
                }
            content = content.replaceFirst("//split", "//var");
        }

        //if split/entry var func was used
        if(variables1.length() >0){
            variables1 = variables1.substring(0, variables1.length()-2);
            variables2 = variables2.substring(0, variables2.length()-2);
            variables1Split = variables1Split.substring(0, variables1Split.length()-2);
            variables2Split = variables2Split.substring(0, variables2Split.length()-2);
        }
        String importVariable;
        String importVariables="";
        String importReplacerText = "const escapeHtml =";

        //shift imports to top level
        while(content.contains("import")){
            Pattern pattern = Pattern.compile("import (.*)");
            Matcher matcher = pattern.matcher(content);
                if (matcher.find())
                {
                    importVariable = matcher.group(0);
                    importVariables=importVariables+importVariable+"\n";
                    System.out.println("Shifted import '"+ matcher.group(0)+ "' from function to top level");
                }
            content = content.replaceFirst(matcher.group(0), "");
        }
        

        //check if external call functionality was used
        while(content.contains("//extstart")){
            content = content.replaceFirst("//extstart","extStart"+Integer.toString(count)+" = Date.now();");
            count++;
        }
        count = 0;
        while(content.contains("//extstop")){
            content = content.replaceFirst("//extstop","extStop"+Integer.toString(count)+" = Date.now();\nextTime.push(extStop"+Integer.toString(count)+" - extStart"+Integer.toString(count)+");");
            count++;
        }
        //content = content.replaceAll(".*return.*;(\r?\n|\r)?","return extTime;");
        Files.write(path1, content.getBytes(charset));
        File mFile = new File(path1.toString());
        FileInputStream fis = new FileInputStream(mFile);
        BufferedReader br = new BufferedReader(new InputStreamReader(fis));
        String result = "";
        String line = "";
        while( (line = br.readLine()) != null){
        result = result + line + "\n"; 
        }
        String extVariables = "var extTime = [];\n";
        for(int i = 0; i < count; i++){
            extVariables += "var extStart"+Integer.toString(i)+";\n" + "var extStop"+Integer.toString(i)+";\n";
        }
        
        
        result = extVariables + result;
        
        FileOutputStream fos = new FileOutputStream(path2.toString());
        fos.write(result.getBytes());
        fos.flush();

        //Azure
        File file = new File(outputFolder+"/index.js");
        BufferedWriter writer = new BufferedWriter(new FileWriter(file, true));
        if(aSyncReq){
            writer.append("\r\nasync function "+templateFunction+"() {");
        }else{
            writer.append("\r\nfunction "+templateFunction+"() {");
        }
        
        BufferedReader reader = new BufferedReader(new FileReader(path2.toString()));
        String currentLine = reader.readLine();
        while(currentLine != null){
            writer.newLine();
            writer.append("   "+currentLine);
            currentLine = reader.readLine();
        }
        reader.close();
        writer.append("\r\n}");
        writer.close();
        
        //split variables within azure
        path = Paths.get(outputFolder+"/index.js");
        charset = StandardCharsets.UTF_8;
        content = new String(Files.readAllBytes(path), charset);
        
        String replacerText = "var experimentID = request.query";
        System.out.println(variablesAzure);
        content = content.replaceAll(replacerText,variablesAzure+replacerText);
        
        replacerText = "//comment for split to replace";
        content = content.replaceAll("//comment for split to replace", varDef+replacerText);
        
        //for recursive functions to be able to call themselves
        if(functionName.length() > 0){
            content = content.replaceAll(functionName, "function"+split.toString());
        }

        if(importVariables.length() > 0){
            content = content.replaceAll(importReplacerText, importVariables+importReplacerText);
        }
        if(varDef.length() > 0 || variables1.length() > 0 || variables2.length() > 0){
            System.out.println("Entered");
            content = content.replaceAll("function1\\(\\);", "function1("+variables1Split+");");
            content = content.replaceAll("function2\\(\\);", "function2("+variables2Split+");");
            content = content.replaceAll("function1\\(\\)", "function1("+variables1+")");
            content = content.replaceAll("function2\\(\\)", "function2("+variables2+")");
        }
        Files.write(path, content.getBytes(charset));
        File delFile = new File(path1.toString());
        delFile.delete();
        delFile = new File(path2.toString());
        delFile.delete();
        return true;
    }
}




