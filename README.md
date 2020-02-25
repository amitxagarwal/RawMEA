# Introduction 
TODO: Give a short introduction of your project. Let this section explain the objectives or the motivation behind this project. 

# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
2.	Software dependencies
3.	Latest releases
4.	API references

# Build and Test
TODO: Describe and show how to build your code and run the tests. 

## Code Analysis
- [Roslyn Analyzers](https://docs.microsoft.com/en-gb/visualstudio/code-quality/install-roslyn-analyzers?view=vs-2019)
- [Serilog analyzer](https://www.nuget.org/packages/SerilogAnalyzer)

* [Codemaid](http://www.codemaid.net/) - Not a NuGet package, but extension. 

### Tips
- Look in the Error List in visual studio, to check if there are any issues to resolve.
- Serilog:
  - Note that Serilog analyser wants Pascal naming (not Camel) in the variables used in the MessageText part:
  - eg.: Log.Information(" The key '{Key}' was found in cache. Value is: '{Guid}'.", key, guid);


# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)