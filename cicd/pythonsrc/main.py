from flask import Flask
import os
import json


mystring = "asdasd"
myint = 9
myarray = [222,2,3,4,5]
mydict = {'studa':'xxxx', 'studa2': 2}
# print(myarray[0])
# print(myint)
# print(mydict['studa'])
# returnDict = dict()
# print('\n\n')




app = Flask(__name__)



@app.route("/")
def hello():
    return "is flask"
    
@app.route("/test")
def test():
    return "test"

@app.route("/myjson")
def myjson():
    arr = os.listdir('/app/pythonsrc/json')
    myjson = dict()
    
    for file in arr:
        if 'json' in file:
            print(file)
            with open('/app/pythonsrc/json/'+file, 'r') as myfile:
                data = myfile.read().rstrip()
            print(json.loads(data))
            myjson[file] = json.loads(data)
    print(json.dumps(myjson, indent=4))
    # print(myjson['test.json']['data']['hostname'])

    return json.dumps(myjson)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True,host='0.0.0.0',port=port)