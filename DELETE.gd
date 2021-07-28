	if faceY == input_dirY:
		if abs(motion.y) > 250: #Speed Y to diagonal>>side
			if input_dirY == 0:
				faceY = 0
		
		if motion.y > 50: #Speed Y to side>>diagonal
			faceY = 1
		elif motion.y < -50:
			faceY = -1
	elif faceY == -input_dirY: #Reversing
		if abs(motion.y) > 100: #Speed Y to diagonal>>side
			if input_dirY == 0:
				faceY = 0
		if motion.y > 50: #Speed Y to side>>diagonal
			faceY = -1
		elif motion.y < -50:
			faceY = 1
	else:
		pass
