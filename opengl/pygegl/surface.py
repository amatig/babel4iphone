from OpenGL.GL import *
from OpenGL.GLU import *

from Image import *

def load(name, pos):
    return Surface(name, pos)


class Surface(object):
    
    def __init__(self, name, pos):
	self.__texture = self.__loadTexture(name)
	
	# image mods
        [self.x, self.y, self.z] = pos
        self.rotation = 0.0
        self.scalar = 1.0
        self.color = [1.0, 1.0, 1.0, 1.0]
        
        # setting display list
        self.__dl = glGenLists(1)
        glNewList(self.__dl, GL_COMPILE)
        glBindTexture(GL_TEXTURE_2D, self.__texture)
        
	glBegin(GL_QUADS)
	glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, 0.0)
	glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, 0.0)
	glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, 0.0)
	glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, 0.0)
	glEnd()
	
        glEndList()
    
    def __loadTexture(self, name):
        image = open(name)
	ix = image.size[0]
	iy = image.size[1]
	
        try:
            image = image.tostring("raw", "RGBA", 0, -1)
        except:
            image = image.tostring("raw", "RGBX", 0, -1)
        
	# Create Texture
	texture_id = glGenTextures(1)
	glBindTexture(GL_TEXTURE_2D, texture_id) # 2d texture (x and y size)
	
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1)
	glTexImage2D(GL_TEXTURE_2D, 
		     0, 
		     GL_RGBA, 
		     ix, 
		     iy, 
		     0, 
		     GL_RGBA, 
		     GL_UNSIGNED_BYTE, 
		     image)
	
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
        
	return texture_id
    
    def delete(self):
        glRemoveTextures([self.__texture])
        del self
    
    def draw(self):
	glPushMatrix()
	
        # matrix stack clear to identity.
        glLoadIdentity()
        
	if self.x > 0 or self.x == -1:
            self.rotation -= 0.1
	
	glTranslatef(self.x, self.y, -6.0 + self.z)
	glColor4f(*self.color)
	glRotatef(self.rotation, 0.0, 0.0, 1.0)
        glScalef(self.scalar, self.scalar, 1)
	
        glCallList(self.__dl)
        glPopMatrix()
