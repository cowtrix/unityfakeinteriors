# Fake Interiors

This is a shader for drawing fake interior volumes within Unity.

<img width="1441" height="1215" alt="image" src="https://github.com/user-attachments/assets/096de310-886d-43cd-bd43-f43cde89b571" />

It can handle lighting to an extent:

<img width="1531" height="1276" alt="image" src="https://github.com/user-attachments/assets/2bd451ff-c2a9-4b98-be02-60c8446b9c41" />

And it's not too bad on performance. We only have 2 cubemap samples and some maths.

<img width="1531" height="1276" alt="image" src="https://github.com/user-attachments/assets/d081813f-a37c-4a9a-86b0-687af48048d3" />

Simply author a cubemap texture like below:

<img width="1564" height="1174" alt="image" src="https://github.com/user-attachments/assets/fd68669e-20ab-4866-b953-716f5d8990e2" />

Note that the backface (to the far right) is unused in the faking of the interior, so we use this as an alpha-blended prop plane which sits halfway across the room. (TODO: customize the depth at which this prop alpha plane is rendered).
