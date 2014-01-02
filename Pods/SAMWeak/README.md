SAMWeak
=======

Obj-C macro for easy creating weak references.

No more retain cycles within blocks.

# Usage

There is only two macros, that creates another weak reference or strong reference.

- `WEAK(__self)`
- `STRONG(__self)`


```objective-c
WEAK(self);
void (^ block)() = ^{
	// now you can use _self variable as weak reference
};
```

```objective-c
WEAK(self);
void (^ block)() = ^{
	STRONG(_self);
 	// now you can use s_self variable as strong reference that is created from weak reference
};
```

# Example

## Simple weak reference:

```objective-c
WEAK(self);
[UIView animateWithDuration:0.25 animations:^{
		_self.frame = CGRectMake(0.0f, 0.0f, 10.0f, 10.0f);
}];
```

## Complex weak and strong referencing:

```objective-c
WEAK(self);
[UIView animateWithDuration:0.25 animations:^{
		STRONG(_self);
		s_self->variable = 0;
}];
```


# CocoaPods is of course supported.
	
	pod 'SAMWeak'
	
