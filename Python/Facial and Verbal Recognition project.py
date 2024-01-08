#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from zipfile import ZipFile

from PIL import Image, ImageDraw, ImageFont
import pytesseract
import cv2 as cv
import numpy as np
pytesseract.pytesseract.tesseract_cmd=r"C:\Program Files\Tesseract-OCR\tesseract.exe"

# loading the face detection classifier
face_cascade = cv.CascadeClassifier('readonly/haarcascade_frontalface_default.xml')
zip = ZipFile('readonly/images.zip')
img_names = zip.namelist()


def searchImageForText(img,search_str):
    #Seach image for search string text
    img = img.convert('L')
    txt=pytesseract.image_to_string(img).lower()
    if search_str.lower() in txt:
        return True
    else:
        return False
    
def searchImageForFaces(img):
    #using cv2, search img for faces and return faces as object list
    cv_img = cv.cvtColor(np.array(img), cv.COLOR_RGB2GRAY)
    blur = cv.GaussianBlur(cv_img,(5,5),0)
    faces = face_cascade.detectMultiScale(blur,scaleFactor=1.33, minNeighbors=5)
    imgs_lst = []
    for x,y,w,h in faces:
        face_img = img.crop((x,y,x+w,y+h))
        if face_img.size[0]> 192: 
            face_img = face_img.resize((192,192))
        if face_img.size[0]< 96: 
            face_img = face_img.resize((96,96))
        imgs_lst.append(face_img)
    return imgs_lst

def displayResults(news_img_d):
    #return text and images as contact sheet (project 1)
    for img_name in news_img_d:
        x,y,w,h = 0,0,192,192
    
        if len(news_img_d[img_name])>0:
            writeHeader("Results found in {}".format(img_name))
            contact_sheet=Image.new('RGB', (w*5,h*(1+(len(news_img_d[img_name])//6))))
            for img in news_img_d[img_name]:
                # Paste the current image into the contact sheet
                contact_sheet.paste(img, (x, y))
                # update x,y position of face images
                if x+w == contact_sheet.width:
                    x=0
                    y=y+h
                else:
                    x=x+w
            # resize and display the contact sheet
            contact_sheet = contact_sheet.resize((int(contact_sheet.width/2),int(contact_sheet.height/2) ))
            display(contact_sheet) 
        else:
            writeHeader("Results found in {}, but there were no faces in that file".format(img_name))

def writeHeader(text):
    #create header that states if there were text/faces found
    header_sheet=Image.new('RGB',(960,45),(255, 255, 255))
    header = ImageDraw.Draw(header_sheet)
    fnt = ImageFont.truetype(r"readonly/OpenSans-Bold.ttf", 15)
    header.text((0, 15), text,(0,0,0),font=fnt)   
    display(header_sheet)
        
def startSearch(search_str):
    print("Searching Images.zip for keyword: '" + search_str + "'")
    print("-----------------------------------------------")
    #base function that starts the search process
    news_img_d = {}
    for img_name in img_names:
        img = Image.open(zip.open(img_name))
        if(searchImageForText(img,search_str)):
            news_img_d[img_name] = searchImageForFaces(img)
    displayResults(news_img_d)

#Test cases with "Christopher" and "Mark"

startSearch("Christopher")
startSearch("Mark")

#user input search keyword
prompt = 'Type in your search keyword:\n'
while True:
    search_input = input(prompt)
    if (len(search_input) > 0) and (' ' not in search_input):
        startSearch(search_input)
        break
    else:
        prompt = 'Invalid input. Please type in your search keyword: \n'



    


# In[ ]:




