# Azure Functions Sample

This directory can be used to create sample Azure Functions. Here are quick examples:

## JavaScript HTTP Trigger

Create a new JavaScript function:

```bash
func init JSSample --javascript
cd JSSample
func new --name HttpExample --template "HTTP trigger"
```

## Python HTTP Trigger

Create a new Python function:

```bash
func init PythonSample --python
cd PythonSample
func new --name HttpExample --template "HTTP trigger"
```

## C# HTTP Trigger

Create a new C# function:

```bash
func init CSharpSample --dotnet
cd CSharpSample
func new --name HttpExample --template "HTTP trigger"
```

After creating any of these samples, run `func start` to test locally.